class PendingSubscription < ActiveRecord::Base
  belongs_to :subscription
  serialize :query_params

  def activated?
    subscription.present?
  end
end
