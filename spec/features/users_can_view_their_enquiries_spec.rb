require 'rails_helper'

feature 'User can view their enquiries' do
  scenario 'Viewing an individual enquiry - enquiry has NOT been responded to' do
    user = create(:user, email: 'john@green.com')
    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    create(:sector, name: 'Animal husbandry')

    enquiry = create(:enquiry,
      opportunity: opportunity,
      user: user,
      first_name: 'John',
      last_name: 'Green',
      company_telephone: '0818118181',
      company_name: 'John Green Plc',
      company_address: '102 Oxford Street, London',
      company_house_number: '123456',
      company_postcode: 'NW1 8TQ',
      company_url: 'http://johngreen.com',
      existing_exporter: 'Yes, in the last year',
      company_sector: 'Animal husbandry',
      company_explanation: 'Your animals are safe with us',
      data_protection: false)

    login_as(user, scope: :user)

    visit '/dashboard/enquiries/' + enquiry.id.to_s

    expect(page).to have_text('Great Opportunity')

    expect(page).to have_text('Your proposal')
    expect(page).to have_text('Your animals are safe with us')
    expect(page).to have_text('Animal husbandry')
    expect(page).to have_text('Yes, in the last year')
    expect(page).to have_text('John Green Plc')

    expect(page).to have_text('Outcome and next steps')
    expect(page).to have_text('Your proposal is under consideration')
  end

  scenario 'Viewing an individual enquiry - enquiry HAS been responded to - Not for third party' do
    user = create(:user, email: 'john@green.com')
    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    create(:sector, name: 'Animal husbandry')

    enquiry = create(:enquiry,
      opportunity: opportunity,
      user: user,
      first_name: 'John',
      last_name: 'Green',
      company_telephone: '0818118181',
      company_name: 'On behalf of John Green Plc',
      company_address: 'London',
      company_house_number: '123456',
      company_postcode: 'NOWT',
      company_url: 'http://johngreen.com',
      existing_exporter: 'Yes, in the last year',
      company_sector: 'Animal husbandry',
      company_explanation: 'Your animals are safe with us',
      data_protection: false)

    create(:enquiry_response, response_type: 5, enquiry: enquiry)

    login_as(user, scope: :user)

    visit '/dashboard/enquiries/' + enquiry.id.to_s

    expect(page).to have_text('Your animals are safe with us')
    expect(page).to have_text('Animal husbandry')
    expect(page).to have_text('Yes, in the last year')
    expect(page).to have_text('On behalf of John Green Plc')
    expect(page).to have_text('Outcome and next steps')

    expect(page).to have_text('You are not eligible for this opportunity')
    expect(page).to have_text('You are a third party')
  end

  scenario 'Viewing an individual enquiry - enquiry HAS been responded to - Not UK registered' do
    user = create(:user, email: 'john@green.com')
    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    create(:sector, name: 'Animal husbandry')

    enquiry = create(:enquiry,
      opportunity: opportunity,
      user: user,
      first_name: 'Guiseppe',
      last_name: 'Verdi',
      company_telephone: '0818118181',
      company_name: 'Verdi Plc',
      company_address: 'Via del Corso, Rome',
      company_house_number: '123456',
      company_postcode: 'NOWT',
      company_url: 'http://verdi.com',
      existing_exporter: 'Yes, in the last year',
      company_sector: 'Animal husbandry',
      company_explanation: 'Your animals are safe with us',
      data_protection: false)

    create(:enquiry_response, response_type: 4, enquiry: enquiry)

    login_as(user, scope: :user)

    visit '/dashboard/enquiries/' + enquiry.id.to_s

    expect(page).to have_text('Your animals are safe with us')
    expect(page).to have_text('Animal husbandry')
    expect(page).to have_text('Yes, in the last year')
    expect(page).to have_text('Verdi Plc')

    expect(page).to have_text('Outcome and next steps')
    expect(page).to have_text('You are not eligible')
    expect(page).to have_text('Your company is not UK registered')

    expect(page).to have_text('Additional suggestions')
    expect(page).to have_link('Visit our international site', href: Figaro.env.TRADE_GREAT_GOV_UK)
  end

  scenario 'Viewing an individual enquiry - enquiry HAS been responded to - Not right for opportunity' do
    user = create(:user, email: 'john@green.com')
    country = create(:country, name: 'Lithuania')
    opportunity = create(:opportunity, :published, countries: [country], title: 'Great Opportunity!', slug: 'great-opportunity')

    enquiry = create(:enquiry,
      opportunity: opportunity,
      user: user,
      first_name: 'Guiseppe',
      last_name: 'Verdi',
      company_telephone: '0818118181',
      company_name: 'Verdi Plc',
      company_address: 'Via del Corso, Rome',
      company_house_number: '123456',
      company_postcode: 'N0WT',
      company_url: 'http://verdi.com',
      existing_exporter: 'Not yet',
      company_sector: 'Animal husbandry',
      company_explanation: 'Your animals are safe with us',
      data_protection: false)

    create(:enquiry_response, response_type: 3, enquiry: enquiry)

    login_as(user, scope: :user)

    visit '/dashboard/enquiries/' + enquiry.id.to_s

    expect(page).to have_text('Your animals are safe with us')
    expect(page).to have_text('Animal husbandry')
    expect(page).to have_text('Not yet')
    expect(page).to have_text('Verdi Plc')

    expect(page).to have_text('Outcome and next steps')
    expect(page).to have_text('Your application will not be taken any further.')
    expect(page).to have_text('Your proposal does not meet the criteria for this opportunity')

    expect(page).to have_text('Additional suggestions')
    expect(page).to have_link('Create a Business Profile', href: 'https://find-a-buyer.export.great.gov.uk/register/company?company_number=123456')
    expect(page).to have_link('Amend your email alerts')

    expect(page).to have_link('Advice and guidance on exporting')
    expect(page).to have_link('Contact a trade advisor', href: 'https://www.contactus.trade.gov.uk/office-finder/N0WT')
  end

  scenario 'Viewing an individual enquiry - enquiry HAS been responded to - Right for opportunity' do
    user = create(:user, email: 'john@green.com')
    country = create(:country, name: 'Lithuania')
    opportunity = create(:opportunity, :published, countries: [country], title: 'Great Opportunity!', slug: 'great-opportunity')

    enquiry = create(:enquiry,
      opportunity: opportunity,
      user: user,
      first_name: 'Guiseppe',
      last_name: 'Verdi',
      company_telephone: '0818118181',
      company_name: 'Verdi Plc',
      company_address: 'Via del Corso, Rome',
      company_house_number: '654321',
      company_postcode: 'N0WT',
      company_url: 'http://verdi.com',
      existing_exporter: 'Yes, in the last year',
      company_sector: 'Animal husbandry',
      company_explanation: 'Your animals are safe with us',
      data_protection: false)

    create(:enquiry_response, response_type: 1, enquiry: enquiry)

    login_as(user, scope: :user)

    visit '/dashboard/enquiries/' + enquiry.id.to_s

    expect(page).to have_text('Your animals are safe with us')
    expect(page).to have_text('Animal husbandry')
    expect(page).to have_text('Yes, in the last year')
    expect(page).to have_text('Verdi Plc')

    expect(page).to have_text('Outcome and next steps')
    expect(page).to have_text('Your application will now move to the next stage.')
    expect(page).to have_text('Your proposal meets the criteria for this opportunity')

    expect(page).to have_text('Additional suggestions')
    expect(page).to have_link('Create a Business Profile', href: 'https://find-a-buyer.export.great.gov.uk/register/company?company_number=654321')
    expect(page).to have_link('Amend your email alerts')

    expect(page).to have_link('Advice and guidance on exporting')
    expect(page).to have_link('Get help with finance')
    expect(page).to have_link('Contact a trade advisor', href: 'https://www.contactus.trade.gov.uk/office-finder/N0WT')
  end

  scenario 'Viewing an individual enquiry - enquiry HAS been responded to - Right for opportunity - With Downloads' do
    user = create(:user, email: 'john@green.com')
    country = create(:country, name: 'Lithuania', exporting_guide_path: '/government/publications/exporting-to-lithuania')
    opportunity = create(:opportunity, :published, countries: [country], title: 'Great Opportunity!', slug: 'great-opportunity')

    enquiry = create(:enquiry,
      opportunity: opportunity,
      user: user,
      first_name: 'Guiseppe',
      last_name: 'Verdi',
      company_telephone: '0818118181',
      company_name: 'Verdi Plc',
      company_address: 'Via del Corso, Rome',
      company_house_number: '654321',
      company_postcode: 'N0WT',
      company_url: 'http://verdi.com',
      existing_exporter: 'Not yet',
      company_sector: 'Animal husbandry',
      company_explanation: 'Your animals are safe with us',
      data_protection: false)

    enquiry_response = create(:enquiry_response, :has_document, response_type: 1, enquiry: enquiry)

    login_as(user, scope: :user)

    visit '/dashboard/enquiries/' + enquiry.id.to_s

    expect(page).to have_text('Your animals are safe with us')
    expect(page).to have_text('Animal husbandry')
    expect(page).to have_text('Not yet')
    expect(page).to have_text('Verdi Plc')

    expect(page).to have_text('Outcome and next steps')
    expect(page).to have_text('Your application will now move to the next stage.')
    expect(page).to have_text('Your proposal meets the criteria for this opportunity')
    expect(page).to have_text('Download documents')

    expect(page).to have_text('Additional suggestions')

    expect(page).to have_link('Amend your email alerts')

    expect(page.find('a', text: 'Advice and guidance on exporting')['href']).to have_content('/new')
    expect(page).to have_link('Read our exporting country guide to Lithuania', href: 'https://www.gov.uk/government/publications/exporting-to-lithuania')

    expect(page).to have_text('Additional suggestions')
    expect(page).to have_link('Create a Business Profile', href: 'https://find-a-buyer.export.great.gov.uk/register/company?company_number=654321')
    expect(page.find('a', text: 'Get help with finance')['href']).to have_content('/get-finance')
    expect(page).to have_link('Contact a trade advisor', href: 'https://www.contactus.trade.gov.uk/office-finder/N0WT')
  end

  scenario 'Viewing the list of enquiries' do
    user = create(:user, email: 'me@example.com')
    opportunity = create(:opportunity, title: 'Hello World', slug: 'hello-world')
    enquiry = create(:enquiry, opportunity: opportunity, user: user)

    login_as(user, scope: :user)
    visit '/dashboard/enquiries/' + enquiry.id.to_s

    expect(page).to have_content('Opportunity details')
    expect(page).to have_content('Hello World')
  end

  scenario 'Viewing enquiries for expired and non-expired opportunities' do
      user = create(:user, email: 'email@example.com')

    enquiry_expired_opportunity = create(:enquiry,
      opportunity: create(:opportunity, title: 'Expired', response_due_on: Time.zone.yesterday),
      user: user)

    enquiry_live_opportunity = create(:enquiry,
      opportunity: create(:opportunity, title: 'Current', response_due_on: Time.zone.tomorrow),
      user: user)

    login_as(user, scope: :user)
    visit '/dashboard/enquiries/' + enquiry_expired_opportunity.id.to_s

    expect(page).to have_content 'Opportunity expired on'

    visit '/dashboard/enquiries/' + enquiry_live_opportunity.id.to_s

    expect(page).to have_content 'Opportunity expires on'
  end

  scenario 'Viewing the list of enquiries only shows my enquiries' do
    user = create(:user, email: 'me@example.com')
    other_user = create(:user, email: 'other@example.com')

    opportunity = create(:opportunity, title: 'Other Opportunity')

    my_enquiry = create(:enquiry, opportunity: opportunity, user: user)
    other_enquiry = create(:enquiry, opportunity: opportunity, user: other_user)

    login_as(user, scope: :user)
    visit '/dashboard/enquiries/' + my_enquiry.id.to_s

    expect(page).to have_content(my_enquiry.company_sector)

    visit '/dashboard/enquiries/' + other_enquiry.id.to_s

    expect(page).to have_content('This page cannot be found')
  end

  scenario 'Viewing an individual enquiry' do
    user = create(:user, email: 'john@green.com')
    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    create(:sector, name: 'Animal husbandry')

    enquiry = create(:enquiry,
      opportunity: opportunity,
      user: user,
      first_name: 'John',
      last_name: 'Green',
      company_telephone: '0818118181',
      company_name: 'John Green Plc',
      company_address: '102 Oxford Street, London',
      company_house_number: '123456',
      company_postcode: 'NW1 8TQ',
      company_url: 'http://johngreen.com',
      existing_exporter: 'Yes, in the last year',
      company_sector: 'Animal husbandry',
      company_explanation: 'Your animals are safe with us',
      data_protection: false)

    login_as(user, scope: :user)
    visit '/dashboard/enquiries/' + enquiry.id.to_s

    expect(page).to have_text('John Green')
    expect(page).to have_text('John Green Plc')
    expect(page).to have_text('Yes, in the last year')
    expect(page).to have_text('Animal husbandry')
    expect(page).to have_text('Your animals are safe with us')
  end

  def fill_in_ckeditor(locator, opts)
    content = opts.fetch(:with).to_json # convert to a safe javascript string
    page.execute_script <<-SCRIPT
    CKEDITOR.instances['#{locator}'].setData(#{content});
    $('textarea##{locator}').text(#{content});
    SCRIPT
  end

  def enquiry_response_not_uk_registered(id)
    create(:service_provider)
    admin = create(:admin)
    create(:opportunity, author: admin)
    login_as(admin)
    visit '/admin/enquiries/' + id
    click_on 'Reply'
    page.find('#li4').click
    wait_for_ajax
    click_on 'Send'
  end

  def enquiry_response_no_third_party(id)
    create(:service_provider)
    uploader = create(:uploader)
    opportunity = create(:opportunity, author: uploader)
    create(:enquiry, opportunity: opportunity)
    login_as(uploader)
    visit '/admin/enquiries/' + id

    click_on 'Reply'
    choose 'Not for third party'
    click_on 'Send'
  end
end
