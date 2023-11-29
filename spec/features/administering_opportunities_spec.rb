# coding: utf-8

require 'rails_helper'

feature 'Administering opportunities' do
  scenario 'Viewing the list of opportunities', skip: true do
    uploader = create(:uploader)
    opportunity = create_opportunity(uploader)
    create_list(:enquiry, 4, opportunity: opportunity)
    login_as(uploader)

    visit admin_opportunities_path

    expect(page).to have_text(opportunity.title)
    expect(page).to have_selector('tbody tr', text: '1')
    expect(page).to have_selector('th', text: 'Title')
    expect(page).to have_selector('th', text: 'Status')
    expect(page).to have_selector('th', text: 'Service provider')
    expect(page).to have_selector('th', text: 'Enquiries received')
    expect(page).to have_selector('th', text: 'Status')
    expect(page).to have_selector('th', text: 'Created date')
    expect(page).to have_selector('th', text: 'Expiry date')
  end

  context 'Viewing a list of opportunities with incomplete data' do
    scenario 'when the status is invalid' do
      uploader = create(:uploader)
      opportunity = create(:opportunity, author: uploader)

      opportunity.update_column(:status, 999)

      login_as(uploader)
      visit admin_opportunities_path
      expect(page).to have_text(opportunity.title)
    end
  end

  scenario 'Viewing an individual opportunity' do
    uploader = create(:uploader)
    opportunity = create_opportunity(uploader)

    login_as(uploader)
    visit admin_opportunities_path
    click_on opportunity.title
    expect(page).to have_text(opportunity.teaser)
    expect(page).to have_text(opportunity.author.name)
  end

  scenario 'Allow editor to edit the slug if we cannot create a unique slug' do
    form = setup_opportunity_form
    create(:opportunity, title: 'Panama – Basic sanitation infrastructure', slug: 'panama-basic-sanitation-infrastructure')
    create(:opportunity, title: 'Panama – Basic sanitation infrastructure', slug: 'panama-basic-sanitation-infrastructure-42')
    allow(Random).to receive(:new).and_return(double(rand: 42))
    uploader = create(:uploader)
    login_as(uploader)

    visit admin_opportunities_path
    click_on 'New opportunity'

    fill_in 'opportunity_title', with: 'Panama - Basic sanitation infrastructure'
    fill_in 'opportunity_teaser', with: 'A new life awaits you in the off-world colonies!'
    fill_in_response_due_on '2023', '06', '04'
    fill_in 'opportunity_description', with: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.'
    fill_in_contact_details
    click_on form['submit_create']

    expect(page).to have_text('Slug has already been taken')

    fill_in 'opportunity_slug', with: 'new-slug'
    click_on form['submit_create']

    expect(page.status_code).to eq 200
    expect(page).to have_text('Created opportunity "Panama - Basic sanitation infrastructure"')
  end

  scenario 'Providing mandatory opportunity fields' do
    form = setup_opportunity_form
    uploader = create(:uploader)
    service_provider = create_service_provider('Italy Rome')
    login_as(uploader)
    visit admin_opportunities_path
    click_on 'New opportunity'

    click_on form['submit_create']

    expect(page.status_code).to eq 422
    expect(page).to have_text('3 errors prevented this opportunity from being saved')
    expect(page).to have_text('Title is missing')
    expect(page).to have_text('Summary is missing')
    expect(page).to have_text('Contacts are missing (2 are required)')

    fill_in 'opportunity_title', with: 'A chance to begin again in a golden land of opportunity and adventure'
    fill_in 'opportunity_teaser', with: 'A new life awaits you in the off-world colonies!'
    fill_in_response_due_on '2023', '06', '04'
    fill_in 'opportunity_description', with: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.'
    select service_provider.name, from: 'Service provider'
    fill_in_contact_details

    click_on form['submit_create']

    expect(page.status_code).to eq 200
    expect(page).to have_text('Created opportunity "A chance to begin again in a golden land of opportunity and adventure"')
  end

  scenario 'Creating a draft opportunity by an Uploader' do
    form = setup_opportunity_form
    uploader = create(:uploader)
    service_provider = create_service_provider('Italy Rome')

    login_as(uploader)
    visit admin_opportunities_path
    click_on 'New opportunity'

    fill_in 'opportunity_title', with: 'A chance to begin again in a golden land of opportunity and adventure'
    fill_in 'opportunity_teaser', with: 'A new life awaits you in the off-world colonies!'
    fill_in_response_due_on '2023', '06', '04'
    fill_in 'opportunity_description', with: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.'
    select service_provider.name, from: 'Service provider'
    fill_in_contact_details

    click_on form['submit_draft']

    expect(page.status_code).to eq 200
    expect(page).to have_text('Saved to draft: "A chance to begin again in a golden land of opportunity and adventure"')
  end

  scenario 'Editing an opportunity' do
    form = setup_opportunity_form
    admin = create(:admin)
    opportunity = create_opportunity(admin, status: 'pending')
    login_as(admin)

    visit admin_opportunities_path
    click_on opportunity.title

    expect(page.status_code).to eq 200
    expect(page).to have_text(opportunity.title)
    expect(page).to have_text('Edit opportunity')
    click_on 'Edit opportunity'

    fill_in 'opportunity_title', with: 'France desperately needs injection moulded widgets'
    fill_in 'opportunity_description', with: 'They can’t get enough of them.'
    click_on form['submit_create']

    expect(page.status_code).to eq 200
    expect(page).to have_text('Updated opportunity "France desperately needs injection moulded widgets"')
    expect(page).to have_text('They can’t get enough of them.')
    expect(page).to have_selector(:link_or_button, 'Publish')
    click_on 'Publish'

    expect(page).to have_selector(:link_or_button, 'Unpublish')
  end

  context 'admins can create opportunities with CPVs' do
    scenario 'and add 1 cpv code', js: true do
      form = setup_opportunity_form
      uploader = create(:uploader)
      service_provider = create_service_provider('Italy Rome')

      login_as(uploader)
      visit admin_opportunities_path
      click_on 'New opportunity'

      fill_in 'opportunity_title', with: 'A chance to begin again in a golden land of opportunity and adventure'
      fill_in 'opportunity_teaser', with: 'A new life awaits you in the off-world colonies!'
      fill_in_response_due_on '2023', '06', '04'
      select service_provider.name, from: 'Service provider'
      fill_in_contact_details
      fill_in "opportunity[cpv_ids][]", with: "150110100080: - Lard"

      click_on form['submit_draft']

      expect(page.status_code).to eq 200
      expect(page).to have_text('Saved to draft: "A chance to begin again in a golden land of opportunity and adventure"')
      expect(Opportunity.last.cpvs.size).to equal(1)
    end

    scenario 'and add multiple cpv codes', js: true do
      form = setup_opportunity_form
      uploader = create(:uploader)
      service_provider = create_service_provider('Italy Rome')

      login_as(uploader)
      visit admin_opportunities_path
      click_on 'New opportunity'

      fill_in 'opportunity_title', with: 'A chance to begin again in a golden land of opportunity and adventure'
      fill_in 'opportunity_teaser', with: 'A new life awaits you in the off-world colonies!'
      fill_in_response_due_on '2023', '06', '04'
      select service_provider.name, from: 'Service provider'
      fill_in_contact_details

      # Lookup does not work in test so creating mock response.
      query = 'food'
      url = js_variable('dit.constants.CPV_CODE_LOOKUP_URL') + '?format=json&description=' + query
      stub_jquery_ajax(url, cpv_search_response)

      # Expect only single cpv field to start.
      cpv_fields = page.all(:css, ".CpvCodeLookup")
      expect(cpv_fields.length).to eq(1)

      click_on 'Add another code'

      # Expect multiple cpv fields now.
      cpv_fields = page.all(:css, ".CpvCodeLookup")
      expect(cpv_fields.length).to eq(2)

      # Get and set the FIRST cpv entry value.
      cpv_fields[0].send_keys('food')
      wait_for_ajax

      cpv_dropdown = find('#' + cpv_fields[0]['aria-controls'], :visible => false)
      
      cpv_option = cpv_dropdown.find(:css, 'li:first-child')
      cpv_option.trigger('click')

      cpv_value_0 = cpv_option['data-value']

      # Get and set the SECOND cpv entry value.
      cpv_fields[1].send_keys('food')
      wait_for_ajax

      cpv_dropdown = find('#' + cpv_fields[1]['aria-controls'], :visible => false)
      cpv_option = cpv_dropdown.find(:css, 'li:last-child')
      cpv_option.trigger('click')

      cpv_value_1 = cpv_option['data-value']

      sleep 1 # DOM update delay, just in case

      # Now check we have set values correctly before form submit.
      expect(cpv_fields[0].value).to eq(cpv_value_0)
      expect(cpv_fields[1].value).to eq(cpv_value_1)

      click_on form['submit_draft']

      # And finally we should have those set values showing on AdminOpportunity#Show
      # with the updated opportunity have correct number of cpv values.
      expect(page.status_code).to eq 200
      expect(page).to have_text('Saved to draft: "A chance to begin again in a golden land of opportunity and adventure"')
      expect(page).to have_text(cpv_value_0[0..8])
      expect(page).to have_text(cpv_value_1[0..8])
      expect(Opportunity.last.cpvs.size).to equal(2)
    end
  end

  context 'service provider dropdown behaviour' do
    scenario 'is not automatically populated by default' do
      setup_opportunity_form
      uploader = create(:editor, role: :uploader)
      create(:service_provider)

      login_as(uploader)

      visit '/export-opportunities/admin/opportunities'
      click_on 'New opportunity'

      expect(page).to have_select('opportunity_service_provider_id')
    end

    scenario 'automatically selects the editor’s service provider if available' do
      setup_opportunity_form
      uploader = create(:editor, role: :uploader, service_provider: create(:service_provider, name: 'Zanzibar'))
      login_as(uploader)

      visit '/export-opportunities/admin/opportunities'
      click_on 'New opportunity'

      expect(page).to have_select('opportunity[service_provider_id]', selected: ['Zanzibar'])
    end
  end

  scenario "publishers can edit other editor's content" do
    form = setup_opportunity_form
    uploader = create(:uploader)
    opportunity = create_opportunity(uploader)
    publisher = create(:publisher)
    login_as(publisher)
    visit admin_opportunities_path

    click_on opportunity.title
    click_on 'Edit opportunity'
    expect(page.status_code).to eq 200

    fill_in 'opportunity_title', with: 'A revised opportunity'
    click_on form['submit_create']

    expect(page.status_code).to eq 200
    expect(page).to have_text('Updated opportunity "A revised opportunity"')
  end

  scenario "administrators can edit other editor's content" do
    form = setup_opportunity_form
    uploader = create(:uploader)
    opportunity = create_opportunity(uploader)
    adminitrator = create(:admin)
    login_as(adminitrator)

    visit admin_opportunities_path
    click_on opportunity.title
    click_on 'Edit opportunity'

    expect(page.status_code).to eq 200

    fill_in 'opportunity_title', with: 'A revised opportunity'
    click_on form['submit_create']

    expect(page.status_code).to eq 200
    expect(page).to have_text('Updated opportunity "A revised opportunity"')
  end

  scenario 'Providing mandatory opportunity fields when editing' do
    form = setup_opportunity_form
    admin = create(:admin)
    opportunity = create_opportunity(admin)
    login_as(admin)

    visit admin_opportunities_path
    expect(page.status_code).to eq 200

    click_on opportunity.title
    click_on 'Edit opportunity'
    expect(page.status_code).to eq 200

    fill_in 'opportunity_title', with: ''
    fill_in 'opportunity_teaser', with: ''
    fill_in 'opportunity_contacts_attributes_0_name', with: ''
    fill_in 'opportunity_contacts_attributes_0_email', with: ''
    click_on form['submit_create']

    expect(page.status_code).to eq 200
    expect(page).to have_text('3 errors prevented this opportunity from being saved')
    expect(page).to have_text('Title is missing')
    expect(page).to have_text('Summary is missing')

    # TODO: This is showing in Browser but...
    # expect(page).to have_text('Contacts Contacts are missing (2 are required)')
    # ...this is showing in test
    expect(page).to have_text('Contacts name is missing')

    fill_in 'opportunity_title', with: 'Join Up now'
    fill_in 'opportunity_teaser', with: 'Service guarantees citizenship'
    fill_in_contact_details
    click_on form['submit_create']

    expect(page.status_code).to eq 200
    expect(page).to have_text('Updated opportunity "Join Up now"')
  end

  scenario 'editing an opportunity that has no contacts' do
    form = setup_opportunity_form
    publisher = create(:publisher)
    invalid_opportunity = create(:opportunity, status: 'trash')
    invalid_opportunity.contacts.destroy_all
    invalid_opportunity.save(validate: false)
    create(:type, name: 'Public Sector')
    create(:value, name: 'More than £100k')
    create(:supplier_preference)

    login_as(publisher)
    visit edit_admin_opportunity_path(invalid_opportunity)
    expect(page.status_code).to eq 200

    fill_in_contact_details
    click_on form['submit_create']

    expect(page).to_not have_text('Contacts are missing')
  end

  scenario 'editing and updating an opportunity that has no contacts' do
    form = setup_opportunity_form
    publisher = create(:publisher)
    invalid_opportunity = create(:opportunity, status: 'trash')
    invalid_opportunity.contacts.destroy_all
    invalid_opportunity.save(validate: false)

    login_as(publisher)
    visit edit_admin_opportunity_path(invalid_opportunity)

    expect(page.status_code).to eq 200

    click_on form['submit_create']

    expect(page).to have_text('Contacts are missing')

    fill_in_contact_details
    click_on 'Save and continue'

    expect(page).to_not have_text('Contacts are missing')
  end

  scenario 'administrators should be able to view responses' do
    uploader = create(:uploader)
    opp = create_opportunity(uploader)
    enquiry = create(:enquiry, opportunity: opp)

    login_as(uploader)
    visit admin_opportunity_path(opp)
    expect(page).to have_content enquiry.company_name
  end

  private

  def create_opportunity(uploader, status: :publish)
    Opportunity.create! \
      title: 'A chance to begin again in a golden land of opportunity and adventure',
      slug: 'a-chance-to-begin-again-in-a-golden-land-of-opportunity-and-adventure',
      teaser: 'A new life awaits you in the off-world colonies!',
      response_due_on: 1.week.from_now,
      description: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.',
      contacts: [
        Contact.new(name: 'Jane Doe', email: 'jane.doe@example.com'),
        Contact.new(name: 'Joe Bloggs', email: 'joe.bloggs@example.com'),
      ],
      service_provider: create_service_provider('Italy Rome'),
      status: status,
      author: uploader,
      source: :post
  end

  def create_country(name)
    Country.create! \
      name: name,
      slug: name.parameterize
  end

  def create_sector(name)
    Sector.create! \
      name: name,
      slug: name.parameterize
  end

  def create_type(name)
    Type.create! \
      name: name,
      slug: name.parameterize
  end

  def create_service_provider(name)
    ServiceProvider.create! \
      name: name
  end

  def create_value(id, name)
    Value.create! \
      name: name,
      slug: id
  end

  def setup_opportunity_form
    create(:type, name: 'Public Sector')
    create(:value, name: 'More than £100k')
    create(:supplier_preference)
    get_content('admin/opportunities')
  end

  def fill_in_contact_details
    fill_in 'opportunity_contacts_attributes_0_name', with: 'Jane Doe'
    fill_in 'opportunity_contacts_attributes_0_email', with: 'jane.doe@example.com'
    fill_in 'opportunity_contacts_attributes_1_name', with: 'Joe Bloggs'
    fill_in 'opportunity_contacts_attributes_1_email', with: 'joe.bloggs@example.com'
  end

  def fill_in_response_due_on(yyyy = '2021', mm = '06', dd = '23')
    select yyyy, from: 'opportunity_response_due_on_1i'
    select mm, from: 'opportunity_response_due_on_2i'
    select dd, from: 'opportunity_response_due_on_3i'
  end
end
