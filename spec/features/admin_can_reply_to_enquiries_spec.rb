require 'rails_helper'
require 'spec/support/integration_helpers'

feature 'admin can reply to enquiries' do
  after(:all) do
    # clean up our files
    Dir[Rails.root.join('tender_sample_*.pdf')].each do |file|
      File.delete(file)
    end
  end

  scenario 'reply to an enquiry - need more information' do
    admin = create(:admin)
    opportunity = create(:opportunity)
    enquiry = create(:enquiry, opportunity: opportunity)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    # need more information
    choose 'Need more information'

    expect(page).to have_content('Contact the company')
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

  scenario 'reply to an enquiry, right for opportunity' do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(15).join('-')

    choose 'Right for opportunity'

    fill_in 'enquiry_response_email_body', with: email_body_text

    click_on 'Preview'

    expect(page).to have_content('Your application will now move to the next stage')

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'reply to an enquiry, go back, select it again from pending, right for opportunity' do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(15).join('-')

    choose 'Right for opportunity'

    fill_in 'enquiry_response_email_body', with: email_body_text

    click_on 'Preview'

    expect(page).to have_content('Your application will now move to the next stage')

    # go back to enquiry show page, select enquiry to reply again from scratch
    visit '/admin/enquiries/' + enquiry.id.to_s
    click_on 'Reply'
    choose 'Right for opportunity'
    click_on 'Preview'

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'reply to an enquiry as a previewer for the opportunity, right for opportunity - with js', js: true do
    create(:service_provider)
    previewer = create(:previewer)
    opportunity = create(:opportunity, author: previewer)
    enquiry = create(:enquiry, opportunity: opportunity)

    login_as(previewer)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in_ckeditor 'enquiry_response_email_body', with: email_body_text

    expect(page.body).to have_content(email_body_text)

    page.find('#li1').click

    wait_for_ajax

    click_on 'Preview'

    wait_for_ajax

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully Remember to record a new CDMS Service delivery')
    expect(page).to have_content('You have no more enquiries to respond to')
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

    choose 'Need more information'

    expect(page).to have_content('Contact the company')
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

    expect(page).to have_content('Your proposal does not meet the criteria for this opportunity')

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'reply to an enquiry as a previewer for the opportunity, not uk business - with js', js: true do
    create(:service_provider)
    previewer = create(:previewer)
    opportunity = create(:opportunity, author: previewer)
    enquiry = create(:enquiry, opportunity: opportunity)

    login_as(previewer)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in_ckeditor 'enquiry_response_email_body', with: email_body_text

    expect(page.body).to have_content(email_body_text)

    page.find('#li4').click

    wait_for_ajax

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully Remember to record a new interaction in Data Hub')
    expect(page).to have_content('You have no more enquiries to respond to')
  end

  scenario 'reply to an enquiry as a previewer for the opportunity, not for third party - with js', js: true do
    # slightly wider window for capybara to allow enough space for screenshot_and_open_page
    page.driver.resize(1300, 1240)

    create(:service_provider)
    previewer = create(:previewer)
    opportunity = create(:opportunity, author: previewer)
    enquiry = create(:enquiry, opportunity: opportunity)
    login_as(previewer)
    visit '/admin/enquiries/' + enquiry.id.to_s
    click_on 'Reply'

    wait_for_ajax

    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in_ckeditor 'enquiry_response_email_body', with: email_body_text
    # expect(page).to have_content(email_body_text)

    page.find('#li5').click

    wait_for_ajax

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully Remember to record a new interaction in Data Hub.')
  end

  scenario 'reply to an enquiry with attachment, valid, right for opportunity - with js', js: true do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in_ckeditor 'enquiry_response_email_body', with: email_body_text

    # choose right for opportunity
    page.find('#li1').click
    # allow_any_instance_of(DocumentController).to receive(:create).and_return(true)
    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_file.pdf', visible: false

    wait_for_ajax
    # page.should_not have_selector?('.isLoading')

    click_on 'Preview'

    wait_for_ajax

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully')
  end

  scenario 'reply to an enquiry with invalid attachment file type - with js', js: true do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')

    fill_in_ckeditor 'enquiry_response_email_body', with: email_body_text

    # choose right for opportunity
    page.find('#li1').click
    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_invalid_extension_file', visible: false

    expect(page.body).to have_content('Wrong file type. Your file should be doc, docx, pdf, ppt, pptx, jpg or png')
  end

  scenario 'reply to an enquiry with invalid attachments, more than 5 - with js', js: true do
    skip('cant attach files with js using capybara')
    Capybara.raise_server_errors = false
    page.driver.browser.js_errors = false

    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.characters(30)

    page.find('#li1').click

    fill_in_ckeditor 'enquiry_response_email_body', with: email_body_text

    expect(page.body).to have_content(email_body_text)

    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_file.pdf', visible: false

    wait_for_ajax

    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_file_2.pdf', visible: false

    wait_for_ajax

    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_file_3.pdf', visible: false

    wait_for_ajax

    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_file_4.pdf', visible: false

    wait_for_ajax

    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_file_5.pdf', visible: false

    wait_for_ajax

    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_file_6.pdf', visible: false

    click_on 'Preview'

    expect(page).to have_content('1 error prevented this enquiry response from being saved')
  end

  scenario 'reply to an enquiry attaching a file with VIRUS - with js', js: true do
    Capybara.raise_server_errors = false
    page.driver.browser.js_errors = false

    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')

    page.find('#li1').click

    fill_in_ckeditor 'enquiry_response_email_body', with: email_body_text
    expect(page.body).to have_content(email_body_text)

    attach_file 'enquiry_response_email_attachment', 'spec/files/tender_sample_infected_file.pdf', visible: false

    expect(page).to have_content('Error. Virus detected in this file')
  end

  scenario 'view enquiry response details at bottom of enquiry page' do
    # create an enquiry and a response
    admin = create(:admin)
    enquiry = create(:enquiry)
    enquiry_response = create(:enquiry_response, enquiry: enquiry)
    enquiry_response['completed_at'] = Time.zone.now
    enquiry_response.save!

    # visit enquiry page
    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    # reply button should not be visible
    expect(page).not_to have_content('Reply')

    # enquiry response details should be visible
    expect(page).to have_content(enquiry_response.editor.name)
    expect(page).to have_content(enquiry_response.email_body)
  end

  scenario 'view and reply to next enquiry, unauthorised-1055 with js, uploader does not get next enquiry to reply from admin', js: true do
    # create admin opportunity
    admin = create(:admin)
    admin_opportunity = create(:opportunity, author: admin)
    create(:enquiry, opportunity: admin_opportunity)

    # create uploader opportunity
    uploader = create(:uploader)
    opportunity = create(:opportunity, author: uploader)
    enquiry = create(:enquiry, opportunity: opportunity)

    login_as(uploader)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in_ckeditor 'enquiry_response_email_body', with: email_body_text

    expect(page.body).to have_content(email_body_text)

    page.find('#li4').click

    wait_for_ajax

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully Remember to record a new interaction in Data Hub')

    # should not see the second enquiry
    expect(page).to_not have_content('Unauthorised')
    expect(page).to have_content('You have no more enquiries to respond to')
  end

  scenario 'view and reply to next enquiry, unauthorised-1055 with js, admin DOES get next enquiry to reply from uploader', js: true do
    # create admin opportunity
    admin = create(:admin)
    admin_opportunity = create(:opportunity, author: admin)
    create(:enquiry, opportunity: admin_opportunity)

    # create uploader opportunity
    uploader = create(:uploader)
    opportunity = create(:opportunity, author: uploader)
    enquiry = create(:enquiry, opportunity: opportunity)

    login_as(admin)
    visit '/admin/enquiries/' + enquiry.id.to_s

    click_on 'Reply'
    expect(page).to have_content('Email body')

    email_body_text = Faker::Lorem.words(10).join('-')
    fill_in_ckeditor 'enquiry_response_email_body', with: email_body_text

    expect(page.body).to have_content(email_body_text)

    page.find('#li4').click

    wait_for_ajax

    click_on 'Send'

    expect(page).to have_content('Reply sent successfully Remember to record a new interaction in Data Hub')

    # should not see the second enquiry
    expect(page).to have_content('Reply to next Enquiry')
  end

  # helper method to fill in our lovely ckeditor textarea
  def fill_in_ckeditor(locator, opts)
    content = opts.fetch(:with).to_json # convert to a safe javascript string
    page.execute_script <<-SCRIPT
    CKEDITOR.instances['#{locator}'].setData(#{content});
    $('textarea##{locator}').text(#{content});
    SCRIPT
  end

  def reload_page
    visit current_path
  end
end
