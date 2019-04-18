require 'elasticsearch'

class Subscription < ApplicationRecord
  include DeviseUserMethods
  include Elasticsearch::Model

  index_name [base_class.to_s.pluralize.underscore, Rails.env].join('_')

  # built in callbacks won't work with our customly indexed taxnomies
  after_commit on: [:create] do
    __elasticsearch__.index_document
  end

  after_commit on: [:update] do
    __elasticsearch__.index_document
  end

  after_commit on: [:destroy] do
    __elasticsearch__.delete_document
  end

  mappings dynamic: 'false' do
    indexes :search_term, analyzer: 'english'
    indexes :confirmed_at, type: :date
    indexes :unsubscribed_at, type: :date
    indexes :title, analyzer: 'english'

    indexes :types do
      indexes :id, type: :keyword
    end

    indexes :values do
      indexes :id, type: :keyword
    end

    indexes :countries do
      indexes :id, type: :keyword
    end

    indexes :sectors do
      indexes :id, type: :keyword
    end
  end

  devise :confirmable

  enum unsubscribe_reason: { not_wanted: 1, not_signed_up: 2, inappropriate: 3, spam: 4, bounced: 5 }

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :sectors
  has_and_belongs_to_many :types
  has_and_belongs_to_many :values
  has_many :notifications, class_name: 'SubscriptionNotification', dependent: :nullify

  belongs_to :user, required: true

  delegate :email, to: :user

  # The user has confirmed their email address.
  scope :confirmed, -> { where.not(confirmed_at: nil) }

  # The user has **not** confirmed their email address.
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  # The user has unsubscribed, and opted out of received further emails.
  scope :unsubscribed, -> { where.not(unsubscribed_at: nil) }

  # The user has **not** opted out, and can be sent emails.
  scope :active, -> { where(unsubscribed_at: nil) }

  def devise_mailer
    SubscriptionMailer
  end

  def as_indexed_json(___ = {})
    as_json(
      only: %i[search_term confirmed_at unsubscribed_at title],
      include: {
        countries: { only: :id },
        types: { only: :id },
        sectors: { only: :id },
        values: { only: :id },
      }
    )
  end

  protected

    def confirmation_required?
      false
    end
end
