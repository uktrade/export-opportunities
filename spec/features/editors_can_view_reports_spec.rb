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
      visit '/admin/reports'

      click_on 'Start'

      expect(page).to have_content('3 Impact Emails sent')
      expect(page).to have_content('2 Impact Emails responded')
      expect(page).to have_content('1 Impact Emails responded with feedback')
      expect(page).to have_content('1 Won')
      expect(page).to have_content('1 Did not win')
      expect(page).to have_content('0 Dont know outcome')
      expect(page).to have_content('0 Dont know, dont want to say')
      expect(page).to have_content('0 No response')
    end
  end

  scenario 'cant view the report when the editor is not an admin' do
    login_as(create(:previewer))

    visit '/admin/reports'

    expect(page).to_not have_content('Start')
  end
end
