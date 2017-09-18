require 'rails_helper'

feature 'User can view their enquiries' do

  scenario 'Viewing an individual enquiry - before enquiry has been responded to' do
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

    expect(page).to have_text('Your animals are safe with us')
    expect(page).to have_text('Animal husbandry')
    expect(page).to have_text('Yes, in the last year')
    expect(page).to have_text('John Green Plc')
    expect(page).to have_text('Outcome and next steps')

    expect(page).to have_text('Your proposal is under consideration')
  end


  scenario 'Viewing an individual enquiry - enquiry has been responded to', :js => true do
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

    respondToEnquiryNotUKRegistered(enquiry.id.to_s)

    login_as(user, scope: :user)

    visit '/dashboard/enquiries/' + enquiry.id.to_s

    expect(page).to have_text('Your animals are safe with us')
    expect(page).to have_text('Animal husbandry')
    expect(page).to have_text('Yes, in the last year')
    expect(page).to have_text('John Green Plc')
    expect(page).to have_text('Outcome and next steps')

    expect(page).to have_text('Your proposal is under consideration')
  end


  scenario 'Viewing the list of enquiries', skip: true do
    user = create(:user, email: 'me@example.com')
    opportunity = create(:opportunity, title: 'Hello World', slug: 'hello-world')
    create(:enquiry, opportunity: opportunity, user: user)

    login_as(user, scope: :user)
    visit dashboard_path

    expect(page).to have_content t('dashboard.heading')
    expect(page).to have_content('Hello World')
  end

  scenario 'Viewing enquiries for expired and non-expired opportunities', skip: true do
    user = create(:user, email: 'email@example.com')

    create(:enquiry,
      opportunity: create(:opportunity, title: 'Expired', response_due_on: Time.zone.yesterday),
      user: user)

    create(:enquiry,
      opportunity: create(:opportunity, title: 'Current', response_due_on: Time.zone.tomorrow),
      user: user)

    login_as(user, scope: :user)
    visit dashboard_path

    items = page.all('.dashboard-item')

    expect(items.first).to have_content 'Opportunity expired on'
    expect(items.last).to have_content 'Opportunity expires on'
  end

  scenario 'Viewing the list of enquiries, with no enquiries', skip: true do
    user = create(:user)

    login_as(user, scope: :user)
    visit dashboard_path

    expect(page).to have_text('You have not yet applied for any export opportunities')
  end

  scenario 'Viewing the list of enquiries only shows my enquiries', skip: true do
    user = create(:user, email: 'me@example.com')
    other_user = create(:user, email: 'other@example.com')

    opportunity = create(:opportunity, title: 'Other Opportunity')

    my_enquiry = create(:enquiry, opportunity: opportunity, user: user)
    other_enquiry = create(:enquiry, opportunity: opportunity, user: other_user)

    login_as(user, scope: :user)
    visit dashboard_path

    expect(page).to have_link(t('enquiry.view'), href: "/dashboard/enquiries/#{my_enquiry.id}")
    expect(page).not_to have_link(t('enquiry.view'), href: "/dashboard/enquiries/#{other_enquiry.id}")
  end

  scenario 'Viewing an individual enquiry', skip: true do
    user = create(:user, email: 'john@green.com')
    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    create(:sector, name: 'Animal husbandry')

    create(:enquiry,
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
    visit dashboard_path

    click_link t('enquiry.view')

    expect(page).to have_text(user.email)
    expect(page).to have_text('John Green')
    expect(page).to have_text('0818118181')
    expect(page).to have_text('John Green Plc')
    expect(page).to have_text('102 Oxford Street, London')
    expect(page).to have_text('123456')
    expect(page).to have_text('NW1 8TQ')
    expect(page).to have_text('http://johngreen.com')
    expect(page).to have_text('Yes, in the last year')
    expect(page).to have_text('Animal husbandry')
    expect(page).to have_text('Your animals are safe with us')
  end

  context 'when the company URL did not include a protocol' do
    scenario 'does not link to a relative URL', skip: true do
      user = create(:user, email: 'john@green.com')
      opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
      create(:sector, name: 'Animal husbandry')

      create(:enquiry,
        opportunity: opportunity,
        user: user,
        company_url: 'www.example.com')

      login_as(user, scope: :user)
      visit dashboard_path

      click_link t('enquiry.view')

      expect(page).to have_text(user.email)

      expect(page).to have_link('www.example.com', href: 'http://www.example.com')
    end
  end


  def fill_in_ckeditor(locator, opts)
    content = opts.fetch(:with).to_json # convert to a safe javascript string
    page.execute_script <<-SCRIPT
    CKEDITOR.instances['#{locator}'].setData(#{content});
    $('textarea##{locator}').text(#{content});
    SCRIPT
  end

  def respondToEnquiryNotUKRegistered(id), :js => true do
    create(:service_provider)
    admin = create(:admin)
    opportunity = create(:opportunity, author: admin)
    login_as(admin)
    visit '/admin/enquiries/' + id

    

    click_on 'Reply'

    save_and_open_page
    
    choose 'Not UK registered'
    click_on 'Send'
  end

  def respondToEnquiryNo3rdparty(id, type)
    create(:service_provider)
    uploader = create(:uploader)
    opportunity = create(:opportunity, author: uploader)
    enquiry = create(:enquiry, opportunity: opportunity)
    login_as(uploader)
    visit '/admin/enquiries/' + id

    click_on 'Reply'
    choose 'Not for third party'
    click_on 'Send'
  end



end
