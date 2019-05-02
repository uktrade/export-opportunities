require 'rails_helper'

RSpec.feature 'Managing feature flags' do
  scenario 'as an authorized user' do
    allow(Figaro.env).to receive(:flipper_whitelist!).and_return('administrator@dit.gov')
    admin = create(:admin, email: 'administrator@dit.gov')
    login_as(admin)

    visit '/export-opportunities/admin/feature-flags'

    expect(page).to have_link 'Add Feature'
  end

  scenario 'as an unauthorized user' do
    allow(Figaro.env).to receive(:flipper_whitelist!).and_return('administrator@dit.gov')
    unauthorized = create(:admin, email: 'someoneelse@dit.gov')
    login_as(unauthorized)

    visit '/export-opportunities/admin/feature-flags'

    expect(page).to have_no_content 'Add Feature'
    expect(page).to have_content t('errors.not_found')
  end
end
