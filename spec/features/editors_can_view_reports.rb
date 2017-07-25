require 'rails_helper'

RSpec.feature 'Editors can view reports' do
  scenario 'Monthly by country VS target report, base case' do
    country = create(:country, name: 'Italy')
    nassau = create(:service_provider, name: 'Nassau', country: country)
    mexico = create(:service_provider, name: 'Mexico', country: country)

    create(:opportunity, :published, service_provider: nassau, first_published_at: Date.new(2017, 4, 13))
    create(:opportunity, :published, service_provider: mexico, first_published_at: Date.new(2017, 5, 20))

    login_as(create(:editor))
    visit '/admin/reports'

    click_on 'Generate'

    expect(page).to have_content(t('admin.stats.opportunities_published', count: 2))
  end

  scenario 'Monthly by country VS target report, CEN network countries' do
    test_totals = {
      opportunities_published_target_cen: 1,
      responses_target_cen: 2,
      opportunities_published_target_nbn: 3,
      responses_target_nbn: 4,
      opportunities_published_target_total: 5,
      responses_target_total: 6,
    }
    allow_any_instance_of(Admin::ReportsController).to receive(:fetch_targets).and_return(test_totals)
    country = create(:country, name: 'Poland', id: 83)
    another_country = create(:country, name: 'Romania', id: 86)
    varsow = create(:service_provider, name: 'Nassau', country: country)
    bucurest = create(:service_provider, name: 'Mexico', country: another_country)

    create(:opportunity, :published, service_provider: varsow, first_published_at: Date.new(2017, 4, 13))
    create(:opportunity, :published, service_provider: bucurest, first_published_at: Date.new(2017, 5, 20))

    login_as(create(:editor))
    visit '/admin/reports'

    click_on 'Generate'

    expect(page).to have_content(t('admin.stats.opportunities_published', count: 2))
  end
end
