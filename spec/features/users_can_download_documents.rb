require 'rails_helper'

RSpec.feature 'User can download Post User Communication Documents' do
  scenario 'The link is valid' do
    skip('TODO: implement')
  end

  scenario 'The link is invalid' do
    mock_sso_with(email: 'enquirer@exporter.com')
    visit '/dashboard/downloads/a_url_does_not_exist'

    expect(page).to have_content('no file found or file expired')
  end
end
