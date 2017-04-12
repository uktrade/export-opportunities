require 'rails_helper'

RSpec.describe SubscriptionNotification do
  it { is_expected.to belong_to(:opportunity) }
  it { is_expected.to belong_to(:subscription) }
end
