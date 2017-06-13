require 'rails_helper'

RSpec.feature 'Editors can view reports' do
  scenario 'Monthly by country VS target report' do
    nassau = create(:service_provider, name: 'Nassau')
    mexico = create(:service_provider, name: 'Mexico')

    create(:opportunity, :published, service_provider: nassau, first_published_at: Date.new(2015, 9, 15))
    create(:opportunity, :published, service_provider: mexico, first_published_at: Date.new(2015, 9, 15))

    login_as(create(:editor))
    visit '/admin/reports'

    click_on 'Generate'

    # expect(page).to have_content('Statistics for all service providers on 15 Sep 2015')
    expect(page).to have_content(t('admin.stats.opportunities_published', count: 2))
  end
end
