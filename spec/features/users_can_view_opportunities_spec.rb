require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'User can view opportunities in list' do
  scenario 'navigates to root' do
    opp = create(:opportunity, title: 'France - Cow required')
    user = create(:user, email: 'test@example.com')
    enquiry = create(:enquiry, opportunity: opp, user: user)

    visit '/'
  end
end
