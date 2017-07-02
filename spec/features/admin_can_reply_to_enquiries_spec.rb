require 'rails_helper'

feature 'admin can reply to enquiries' do
  scenario 'reply to an enquiry without attachment, valid' do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.characters(30)
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

  scenario 'add an attachment to queue before submitting form', js: true do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'

    expect(page).to have_content('You may add up to 5 attachments')

    attach_file('enquiry_response[email_attachment][]', ['spec/tender_sample_file.txt'], visible: false)
    
    expect(page).to have_content('File 1: tender_sample_file.txt')
  end

  scenario 'add multiple attachments to queue before submitting form', js: true do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'

    expect(page).to have_content('You may add up to 5 attachments')

    attach_file('enquiry_response[email_attachment][]', ['spec/tender_sample_file.txt', 'spec/tender_sample_file_2.txt'], visible: false)
    
    expect(page).to have_content('File 1: tender_sample_file.txt')
    expect(page).to have_content('File 2: tender_sample_file_2.txt')
  end

  scenario 'not add more than 5 files to queue before submitting form', js: true do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'

    expect(page).to have_content('You may add up to 5 attachments')

    attach_file('enquiry_response[email_attachment][]', 
        ['spec/tender_sample_file.txt',
         'spec/tender_sample_file_2.txt',
         'spec/tender_sample_file_3.txt',
         'spec/tender_sample_file_4.txt',
         'spec/tender_sample_file_5.txt',
         'spec/tender_sample_file_6.txt',
            ], visible: false)
    
    expect(page).to have_content('Too many filez')
  end

  scenario 'remove attachments from queue before submitting form', js: true do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'

    expect(page).to have_content('You may add up to 5 attachments')

    attach_file('enquiry_response[email_attachment][]', ['spec/tender_sample_file.txt', 'spec/tender_sample_file_2.txt'], visible: false)
    
    expect(page).to have_content('File 1: tender_sample_file.txt')
    expect(page).to have_content('File 2: tender_sample_file_2.txt')

    click_on 'Remove files'

    expect(page).to have_content('No files selected')
  end

  scenario 'reply to an enquiry with attachment, valid' do
    skip('TO-DO Multiple file upload function')
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in 'enquiry_response_email_body', with: email_body_text
    expect(page).to have_content(email_body_text)

    attach_file 'enquiry_response_email_attachment', 'spec/tender_sample_file.txt'

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'reply to an enquiry with invalid attachment file type' do
    skip('TO-DO Multiple file upload function')
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in 'enquiry_response_email_body', with: email_body_text
    expect(page).to have_content(email_body_text)

    attach_file 'enquiry_response[email_attachment][]', ['spec/tender_sample_invalid_extension_file']

    click_on 'Send'

    expect(page).to have_content('2 errors prevented this enquiry response from being saved')
  end

  scenario 'reply to an enquiry with invalid attachment file size' do
    skip('TO-DO Multiple file upload function')
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.characters(30)
    fill_in 'enquiry_response_email_body', with: email_body_text
    expect(page).to have_content(email_body_text)

    attach_file 'enquiry_response_email_attachment', 'spec/tender_sample_pico_file.txt'

    click_on 'Send'

    expect(page).to have_content('2 errors prevented this enquiry response from being saved')
  end

  scenario 'reply to an enquiry with invalid mail length (has to be 30 chars)' do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.characters(29)
    fill_in 'enquiry_response_email_body', with: email_body_text
    expect(page).to have_content(email_body_text)

    click_on 'Send'

    expect(page).to have_content('1 error prevented this enquiry response from being saved')
  end

  scenario 'reply to an enquiry attaching a file with VIRUS' do
    skip('TO-DO Multiple file upload function')
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in 'enquiry_response_email_body', with: email_body_text
    expect(page).to have_content(email_body_text)

    attach_file 'enquiry_response_email_attachment', 'spec/tender_sample_infected_file.txt'

    click_on 'Send'

    expect(page).to have_content('Your attachment is INFECTED. Please contact Export Opportunities helpdesk immediately')
  end

  scenario 'reply to an enquiry attaching a file that can not be scanned' do
    skip
  end
end
