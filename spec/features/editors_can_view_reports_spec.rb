require 'rails_helper'

RSpec.feature 'Editors can view reports' do
  scenario 'for impact email' do
    now = Time.utc(2015, 6, 23, 5, 0)

    service_provider = create(:service_provider, name: 'A provider of services')
    create(:enquiry_feedback, responded_at: now - 1.day, created_at: now - 7.days, initial_response: 1, message: 'did not win')
    create(:enquiry_feedback, created_at: now - 7.days)
    create(:enquiry_feedback, created_at: now - 9.days, responded_at: now - 8.days)
    create(:enquiry_feedback, responded_at: now - 7.days, created_at: now - 7.days, initial_response: 0)

    login_as(create(:editor, service_provider: service_provider, role: :administrator))

    Timecop.freeze(now) do
      visit '/export-opportunities/admin/reports'

      click_on 'Start'

      expect(page).to have_content('3 sent')
      expect(page).to have_content('2 responses')
      expect(page).to have_content('1 responses with feedback')
      expect(page).to have_content('1 won the business')
      expect(page).to have_content('1 didn\'t win the business')
      expect(page).to have_content('0 was contacted, don\'t know outcome')
      expect(page).to have_content('0 don\'t know / don\'t want to say')
      expect(page).to have_content('0 wasn\'t contacted')
    end
  end

  scenario 'cant view the report when the editor is not an admin' do
    login_as(create(:previewer))

    visit '/export-opportunities/admin/reports'

    expect(page).to_not have_content('Start')
  end

  scenario 'Monthly by country VS target report, base case', skip: true do
    country = create(:country, name: 'Italy')
    nassau = create(:service_provider, name: 'Nassau', country: country)
    mexico = create(:service_provider, name: 'Mexico', country: country)

    create(:opportunity, :published, service_provider: nassau, first_published_at: Date.new(2017, 4, 13))
    create(:opportunity, :published, service_provider: mexico, first_published_at: Date.new(2017, 5, 20))

    login_as(create(:editor, role: :administrator))
    visit '/export-opportunities/admin/reports'

    click_on 'Generate'

    expect(page).to have_content('The requested Monthly Outcome against Targets by Country report has been emailed to you')
  end
end
