require 'elasticsearch'

class Opportunity < ApplicationRecord
  include Elasticsearch::Model
  index_name [base_class.to_s.pluralize.underscore, Rails.env].join('_')

  # built in callbacks won't work with our custom indexed taxonomies
  after_commit on: [:create] do
    __elasticsearch__.index_document
  end

  after_commit on: [:update] do
    __elasticsearch__.delete_document
    __elasticsearch__.index_document
  end

  after_commit on: [:destroy] do
    __elasticsearch__.delete_document
  end

  settings index: { max_result_window: 100_000 } do
    mappings dynamic: 'false' do
      indexes :title, analyzer: 'english'
      indexes :teaser, analyzer: 'english'
      indexes :description, analyzer: 'english'

      indexes :types do
        indexes :slug, type: :keyword
      end

      indexes :values do
        indexes :slug, type: :keyword
      end

      indexes :countries do
        indexes :slug, type: :keyword
      end

      indexes :sectors do
        indexes :slug, type: :keyword
      end

      indexes :response_due_on, type: :date
      indexes :first_published_at, type: :date
      indexes :updated_at, type: :date
      indexes :status, type: :keyword
      indexes :source, type: :keyword
    end
  end

  has_paper_trail class_name: 'OpportunityVersion', only: [:status]

  extend FriendlyId
  friendly_id :title, use: %i[slugged finders]

  CONTACTS_PER_OPPORTUNITY = 2
  paginates_per 10
  TITLE_LENGTH_LIMIT = 250.freeze
  TEASER_LENGTH_LIMIT = 140.freeze

  enum status: { pending: 1, publish: 2, draft: 3, trash: 4 }
  enum ragg: { undefined: 0, blue: 2, green: 4, amber: 6, red: 8 }
  enum source: { post: 0, volume_opps: 1, buyer: 2 }
  enum original_language: { en: 0, de: 1, es: 2, fr: 3, it: 4, nl: 5, pl: 6 }

  enum request_type: { goods: 0, services: 2 }
  enum request_usage: { samples: 0, sell_goods: 2, use_product: 4 }
  enum enquiry_interaction: { post_response: 0, third_party: 2 }

  include PgSearch

  pg_search_scope :fuzzy_match,
    against: %i[title teaser description],
    using: { tsearch: { tsvector_column: 'tsv', dictionary: 'english' } }

  pg_search_scope :admin_match,
    against: %i[title teaser description],
    associated_against: { author: %i[name email] },
    using: { tsearch: { tsvector_column: 'tsv', dictionary: 'english' } }

  scope :published, -> { where(status: Opportunity.statuses[:publish]) }
  scope :applicable, -> { where('response_due_on >= ?', Time.zone.today) }
  scope :drafted, -> { where(status: Opportunity.statuses[:draft]) }

  belongs_to :service_provider, required: true
  belongs_to :author, class_name: 'Editor', required: true
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :sectors
  has_and_belongs_to_many :types
  has_and_belongs_to_many :values
  has_and_belongs_to_many :supplier_preferences
  has_many :contacts, dependent: :destroy
  has_many :comments, -> { order(:created_at) }, class_name: 'OpportunityComment'
  has_many :enquiries
  has_many :subscription_notifications
  has_many :opportunity_checks
  has_many :opportunity_sensitivity_checks
  has_many :opportunity_cpvs
  has_one :opportunity_buyer

  accepts_nested_attributes_for :contacts, reject_if: :all_blank

  validates :title, presence: true, length: { maximum: TITLE_LENGTH_LIMIT }
  validate :teaser, :teaser_validations
  validates :response_due_on, presence: true
  validate :contacts, :contact_validations
  validate :target_url, :enquiry_url_validations

  def enquiry_url_validations
    if source == 'post' && custom_url_service_provider?
      if not_a_url?(target_url)
        errors.add(:target_url, 'The custom target enquiry URL is not a valid URL. A valid URL starts with http:// or https://')
      end
    end
  end

  def contact_validations
    if source == 'post'
      errors.add(:contacts, "Contacts are missing (#{CONTACTS_PER_OPPORTUNITY} are required)") if contacts.length < CONTACTS_PER_OPPORTUNITY
    end
  end

  def teaser_validations
    if source == 'post'
      if teaser.present?
        errors.add(:teaser, "can't be more than #{TEASER_LENGTH_LIMIT}") if teaser.length > TEASER_LENGTH_LIMIT
      else
        errors.add(:teaser, 'is missing')
      end
    end
  end

  validates :slug, presence: true, uniqueness: true

  # Database triggers to make Postgres rebuild its fulltext search
  # index whenever an opportunity is created or updated
  trigger.before(:insert, :update).for_each(:row).nowrap do
    "tsvector_update_trigger(tsv, 'pg_catalog.english', title, teaser, description);"
  end

  def slug=(slug)
    return if slug.nil?
    self[:slug] = slug.parameterize
  end

  # The authors of `pg_search` would prefer a nil value to return an empty set
  # https://github.com/Casecommons/pg_search/issues/49
  def self.search(query)
    results = all
    results = results.fuzzy_match(query) if query.present?
    results
  end

  def self.public_search(dit_boost_search: false, search_term: nil, filters: NullFilter.new, limit: 0, sort:)
    query = OpportunitySearchBuilder.new(dit_boost_search: dit_boost_search, search_term: search_term, sectors: filters.sectors, countries: filters.countries, opportunity_types: filters.types, values: filters.values, sort: sort, sources: filters.sources).call

    ElasticSearchFinder.new.call(query[:search_query], query[:search_sort], limit)
  end

  def self.public_featured_industries_search(sector, search_term)
    search_query =
      {
        "bool": {
          "should": [
            {
              "bool": {
                "must": [
                  {
                    "match": {
                      "source": 'post',
                    },
                  },
                  {
                    "match": {
                      "sectors.slug": sector,
                    },
                  },
                  {
                    "match": {
                      "status": 'publish',
                    },
                  },
                  "range": {
                    "response_due_on": {
                      "gte": 'now/d',
                    },
                  },
                ],
              },
            },
            {
              "bool": {
                "must": [
                  {
                    "match": {
                      "source": 'volume_opps',
                    },
                  },
                  {
                    "multi_match": {
                      "query": search_term,
                      "fields": %w[title^5 teaser^2 description],
                      "operator": 'or',
                    },
                  },
                  {
                    "match": {
                      "status": 'publish',
                    },
                  },
                  "range": {
                    "response_due_on": {
                      "gte": 'now/d',
                    },
                  },
                ],
              },
            },
          ],
        },
      }

    search_sort = [{ "response_due_on": { "order": 'asc' } }]

    ElasticSearchFinder.new.call(search_query, search_sort, 100)
  end

  def as_indexed_json(_ = {})
    as_json(
      only: %i[title teaser description created_at updated_at status response_due_on first_published_at source],
      include: {
        countries: { only: :slug },
        types: { only: :slug },
        sectors: { only: :slug },
        values: { only: :slug },
      }
    )
  end

  def to_param
    slug || id
  end

  def expired?
    response_due_on < Time.zone.today
  end

  def published?
    status == :publish
  end

  def custom_url_service_provider?
    service_provider && service_provider.name == 'DFID'
  end

  def not_a_url?(target_url)
    return false if target_url.blank?
    target_url.downcase.match(%r{^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$}).blank?
  end

  def tender?
    false
  end
end
