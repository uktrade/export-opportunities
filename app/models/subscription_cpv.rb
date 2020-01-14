class SubscriptionCpv < ApplicationRecord
  belongs_to :subscription

  after_commit on: [:create, :update, :destroy] do
    subscription.__elasticsearch__.index_document
  end

end
