require 'elasticsearch/model'

class Opportunity < ActiveRecord::Base
  include Elasticsearch::Model

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
    indexes :status, type: :keyword
  end

  has_paper_trail class_name: 'OpportunityVersion', only: [:status]

  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  CONTACTS_PER_OPPORTUNITY = 2
  paginates_per 20
  TITLE_LENGTH_LIMIT = 80.freeze
  TEASER_LENGTH_LIMIT = 140.freeze

  enum status: { pending: 1, publish: 2, draft: 3, trash: 4 }

  include PgSearch

  pg_search_scope :fuzzy_match,
    against: [:title, :teaser, :description],
    using: { tsearch: { tsvector_column: 'tsv', dictionary: 'english' } }

  pg_search_scope :admin_match,
    against: [:title, :teaser, :description],
    associated_against: { author: [:name, :email] },
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

  accepts_nested_attributes_for :contacts, reject_if: :all_blank

  validates :title, presence: true, length: { maximum: TITLE_LENGTH_LIMIT }
  validates :teaser, presence: true, length: { maximum: TEASER_LENGTH_LIMIT }
  validates :response_due_on, :description, presence: true
  validates :contacts, length: { is: CONTACTS_PER_OPPORTUNITY }
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

  def as_indexed_json(_ = {})
    as_json(
      only: [:title, :teaser, :description],
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
end
