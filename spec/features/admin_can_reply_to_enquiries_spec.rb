require 'rails_helper'

feature 'admin can reply to enquiries' do
  scenario 'reply to an enquiry' do
    admin = create(:admin)
    opportunity = create(:opportunity)
    enquiry = create(:enquiry, opportunity: opportunity)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    editor_signature = Faker::Lorem.words(10).join('-')
    fill_in 'enquiry_response_email_body', with: email_body_text
    fill_in 'enquiry_response_signature', with: editor_signature

    expect(page).to have_content(email_body_text)

    # need more information
    choose 'Need more information'

    # go to next page, preview
    click_on 'Preview'

    expect(page).to have_content(email_body_text)
    expect(page).to have_content('Thank you for your interest in the export opportunity: ' + opportunity.title)
    expect(page).to have_content('You have not provided enough information')
  end

  scenario 'reply to an enquiry with invalid mail length (has to be 30 chars)' do
    skip('TODO: unskip once we reintroduce the 30 chars limit')
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.characters(29)
    editor_signature = Faker::Lorem.words(10).join('-')

    fill_in 'enquiry_response_email_body', with: email_body_text
    fill_in 'enquiry_response_signature', with: editor_signature

    expect(page).to have_content(email_body_text)

    # need more information
    choose 'Need more information'

    click_on 'Preview'

    expect(page).to have_content('1 error prevented this enquiry response from being saved')
  end

  scenario 'reply to an enquiry with blank mail - FAIL' do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    editor_signature = Faker::Lorem.words(10).join('-')

    fill_in 'enquiry_response_signature', with: editor_signature

    choose 'Need more information'

    click_on 'Preview'

    expect(page).to have_content('1 error prevented this enquiry response from being saved')
  end

  scenario 'reply to an enquiry with attachment choosing right for opportunity' do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(15).join('-')

    choose 'Right for opportunity'

    fill_in 'enquiry_response_email_body', with: email_body_text

    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_file.txt'

    expect(page).to have_content(email_body_text)
    click_on 'Preview'

    expect(page).to have_content('Your application will now move to the next stage')

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'reply to an enquiry as an uploader from the same service provider, need more information choice' do
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

    choose 'Need more information'

    click_on 'Preview'

    expect(page).to have_content('need more information')

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'reply to an enquiry as an uploader for the opportunity, not right for opportunity choice' do
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

    choose 'Not right for opportunity'

    click_on 'Preview'

    expect(page).to have_content('Your application does not meet the criteria for this opportunity')

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'reply to an enquiry as a previewer for the opportunity, not uk business' do
    create(:service_provider)
    previewer = create(:previewer)
    opportunity = create(:opportunity, author: previewer)
    enquiry = create(:enquiry, opportunity: opportunity)
    login_as(previewer)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in 'enquiry_response_email_body', with: email_body_text
    expect(page).to have_content(email_body_text)

    choose 'Not UK registered'

    click_on 'Preview'

    expect(page).to have_content('is not UK registered')

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'reply to an enquiry as a previewer for the opportunity, not for third party' do
    create(:service_provider)
    previewer = create(:previewer)
    opportunity = create(:opportunity, author: previewer)
    enquiry = create(:enquiry, opportunity: opportunity)
    login_as(previewer)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in 'enquiry_response_email_body', with: email_body_text
    expect(page).to have_content(email_body_text)

    choose 'Not for third party'

    click_on 'Preview'

    expect(page).to have_content('You are a third party')

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

  scenario 'reply to an enquiry with attachment, valid, right for opportunity', js: true do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in_ckeditor 'enquiry_response_email_body', with: email_body_text

    # choose right for opportunity
    page.find('#response_type_1').trigger('click')
    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_file.pdf', visible: false

    click_on 'Preview'

    wait_for_ajax

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'reply to an enquiry with invalid attachment file type', js: true do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')

    fill_in_ckeditor 'enquiry_response_email_body', with: email_body_text

    # choose right for opportunity
    page.find('#response_type_1').trigger('click')
    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_invalid_extension_file', visible: false

    expect(page.body).to have_content('Wrong file type. Your file should be doc, docx, pdf, ppt, pptx, jpg or png')
  end

  scenario 'reply to an enquiry with invalid attachment file size' do
    skip
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.characters(30)
    fill_in 'enquiry_response_email_body', with: email_body_text
    expect(page).to have_content(email_body_text)

    attach_file 'enquiry_response_attachments', 'spec/files/tender_sample_pico_file.txt'

    click_on 'Send'

    expect(page).to have_content('2 errors prevented this enquiry response from being saved')
  end

  scenario 'reply to an enquiry attaching a file with VIRUS', js: true do
    skip('TODO: poltergeist cant click on XY error..')
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')

    choose 'Right for opportunity'

    fill_in 'enquiry_response_email_body', with: email_body_text
    expect(page).to have_content(email_body_text)

    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_infected_file.txt'

    expect(page).to have_content('Something has gone wrong. Please try again. If the problem persists, contact us.')
    expect(page).to have_content('tender_sample_infected_file')
  end

  scenario 'reply to an enquiry attaching a file that can not be scanned' do
    skip
  end

  # helper method to fill in our lovely ckeditor textarea
  def fill_in_ckeditor(locator, opts)
    content = opts.fetch(:with).to_json # convert to a safe javascript string
    page.execute_script <<-SCRIPT
    CKEDITOR.instances['#{locator}'].setData(#{content});
    $('textarea##{locator}').text(#{content});
    SCRIPT
  end
end
