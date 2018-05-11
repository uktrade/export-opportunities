require 'elasticsearch'

class Opportunity < ApplicationRecord
  include Elasticsearch::Model
  index_name [base_class.to_s.pluralize.underscore, Rails.env].join('_')

  # built in callbacks won't work with our customly indexed taxnomies
  after_commit on: [:create] do
    # __elasticsearch__.delete_document
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
  has_many :contacts, dependent: :destroy
  has_many :comments, -> { order(:created_at) }, class_name: 'OpportunityComment'
  has_many :enquiries
  has_many :subscription_notifications
  has_many :opportunity_checks
  has_many :opportunity_sensitivity_checks
  has_many :opportunity_cpvs

  accepts_nested_attributes_for :contacts, reject_if: :all_blank

  validates :title, presence: true, length: { maximum: TITLE_LENGTH_LIMIT }
  validates :teaser, presence: true, length: { maximum: TEASER_LENGTH_LIMIT }
  validates :response_due_on, :description, presence: true
  validates :contacts, length: { is: CONTACTS_PER_OPPORTUNITY }

  # validate :contacts, :contact_validations
  # def contact_validations
  #   if self.source && self.source.volume_opps?
  #     contacts.length == 1
  #   else
  #     contacts.length >= 2
  #   end
  # end
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

  def self.public_search(search_term: nil, filters: NullFilter.new, sort:)
    query = OpportunitySearchBuilder.new(search_term: search_term, sectors: filters.sectors, countries: filters.countries, opportunity_types: filters.types, values: filters.values, sort: sort).call
    ElasticSearchFinder.new.call(query[:search_query], query[:search_sort])
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
end
