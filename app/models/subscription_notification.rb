require 'elasticsearch/model'

class SubscriptionNotification < ApplicationRecord
  belongs_to :opportunity
  belongs_to :subscription
  include Elasticsearch::Model
  index_name [base_class.to_s.pluralize.underscore, Rails.env].join('_')
end
