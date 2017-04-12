class Subscription < ActiveRecord::Base
  include DeviseUserMethods

  devise :confirmable

  enum unsubscribe_reason: { not_wanted: 1, not_signed_up: 2, inappropriate: 3, spam: 4, bounced: 5 }

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :sectors
  has_and_belongs_to_many :types
  has_and_belongs_to_many :values
  has_many :notifications, class_name: 'SubscriptionNotification'

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

  protected

  def confirmation_required?
    false
  end
end
