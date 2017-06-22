require 'rails_helper'

feature 'admin can reply to enquiries' do
  scenario 'reply to an enquiry' do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in 'enquiry_response_email_body', with: email_body_text
    expect(page).to have_content(email_body_text)

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'reply to an enquiry as an uploader from the same service provider' do
    service_provider = create(:service_provider)
    uploader = create(:uploader, service_provider_id: service_provider.id)
    opportunity = create(:opportunity, service_provider_id: service_provider.id)
    enquiry = create(:enquiry, opportunity: opportunity)
    login_as(uploader)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in 'enquiry_response_email_body', with: email_body_text
    expect(page).to have_content(email_body_text)

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'reply to an enquiry as an uploader for the opportunity' do
    create(:service_provider)
    uploader = create(:uploader)
    opportunity = create(:opportunity, author: uploader)
    enquiry = create(:enquiry, opportunity: opportunity)
    login_as(uploader)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in 'enquiry_response_email_body', with: email_body_text
    expect(page).to have_content(email_body_text)

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'view enquiry response details at bottom of enquiry page' do
    # create an enquiry and a response
    admin = create(:admin)
    enquiry = create(:enquiry)
    enquiry_response = create(:enquiry_response, enquiry: enquiry)

    # visit enquiry page
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    # reply button should not be visible
    expect(page).not_to have_content('Reply')

    # enquiry response details should be visible
    expect(page).to have_content(enquiry_response.editor.name)
    expect(page).to have_content(enquiry_response.email_body)
  end
end
