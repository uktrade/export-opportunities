class PendingSubscription < ApplicationRecord
  belongs_to :subscription
  serialize :query_params

  def activated?
    subscription.present?
  end
end
