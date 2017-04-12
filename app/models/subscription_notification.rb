class SubscriptionNotification < ActiveRecord::Base
  belongs_to :opportunity
  belongs_to :subscription
end
