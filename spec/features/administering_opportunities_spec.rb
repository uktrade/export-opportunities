# coding: utf-8
require 'rails_helper'

feature 'Administering opportunities' do
  scenario 'Viewing the list of opportunities' do
    uploader = create(:uploader)
    opportunity = create_opportunity(uploader)
    create_list(:enquiry, 4, opportunity: opportunity)

    login_as(uploader)
    visit admin_opportunities_path
    expect(page).to have_text(opportunity.title)
    expect(page).to have_selector('td.numeric', text: '4')

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
    create(:opportunity, title: 'Panama – Basic sanitation infrastructure', slug: 'panama-basic-sanitation-infrastructure')
    create(:opportunity, title: 'Panama – Basic sanitation infrastructure', slug: 'panama-basic-sanitation-infrastructure-42')

    allow(Random).to receive(:new).and_return(double(rand: 42))

    uploader = create(:uploader)
    country = create_country('America')
    sector = create_sector('Aerospace')
    type = create_type('Public Sector')
    value = create_type('More than £100k')
    service_provider = create_service_provider('Italy Rome')

    login_as(uploader)
    visit admin_opportunities_path
    click_on 'New opportunity'

    fill_in 'Title', with: 'Panama - Basic sanitation infrastructure'
    check country.name
    check sector.name
    check type.name
    check value.name
    fill_in t('admin.opportunity.teaser_field'), with: 'A new life awaits you in the off-world colonies!'
    select '2016', from: 'opportunity_response_due_on_1i'
    select 'June', from: 'opportunity_response_due_on_2i'
    select '4', from: 'opportunity_response_due_on_3i'
    fill_in t('admin.opportunity.description_field'), with: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.'
    select service_provider.name, from: 'Service provider'

    name_fields = find_all(:fillable_field, 'Name')
    email_fields = find_all(:fillable_field, 'Email')

    name_fields[0].set 'Jane Doe'
    email_fields[0].set 'jane.doe@example.com'
    name_fields[1].set 'Joe Bloggs'
    email_fields[1].set 'joe.bloggs@example.com'

    click_on 'Create Opportunity'

    expect(page).to have_text('Slug has already been taken')

    fill_in 'Slug', with: 'new-slug'
    click_on 'Create Opportunity'

    expect(page.status_code).to eq 200
    expect(page).to have_text('Created opportunity "Panama - Basic sanitation infrastructure"')
  end

  scenario 'Providing mandatory opportunity fields' do
    uploader = create(:uploader)
    service_provider = create_service_provider('Italy Rome')

    login_as(uploader)
    visit admin_opportunities_path
    click_on 'New opportunity'

    click_on 'Create Opportunity'

    expect(page.status_code).to eq 422
    expect(page).to have_text('5 errors prevented this opportunity from being saved')
    expect(page).to have_text('Title is missing')
    expect(page).to have_text("#{t('activerecord.attributes.opportunity.teaser')} is missing")
    expect(page).to have_text("#{t('activerecord.attributes.opportunity.response_due_on')} is missing")
    expect(page).to have_text('Description is missing')
    expect(page).to have_text('Contacts are missing (2 are required)')

    fill_in 'Title', with: 'A chance to begin again in a golden land of opportunity and adventure'
    fill_in t('admin.opportunity.teaser_field'), with: 'A new life awaits you in the off-world colonies!'
    select '2016', from: 'opportunity_response_due_on_1i'
    select 'July', from: 'opportunity_response_due_on_2i'
    select '4', from: 'opportunity_response_due_on_3i'
    fill_in t('admin.opportunity.description_field'), with: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.'
    select service_provider.name, from: 'Service provider'

    name_fields = find_all(:fillable_field, 'Name')
    email_fields = find_all(:fillable_field, 'Email')

    name_fields[0].set 'Jane Doe'
    email_fields[0].set 'jane.doe@example.com'
    name_fields[1].set 'Joe Bloggs'
    email_fields[1].set 'joe.bloggs@example.com'

    click_on 'Create Opportunity'

    expect(page.status_code).to eq 200
    expect(page).to have_text('Created opportunity "A chance to begin again in a golden land of opportunity and adventure"')
  end

  scenario 'Creating a draft opportunity by an Uploader' do
    uploader = create(:uploader)
    service_provider = create_service_provider('Italy Rome')

    login_as(uploader)
    visit admin_opportunities_path
    click_on 'New opportunity'

    fill_in 'Title', with: 'A chance to begin again in a golden land of opportunity and adventure'
    fill_in t('admin.opportunity.teaser_field'), with: 'A new life awaits you in the off-world colonies!'
    select '2016', from: 'opportunity_response_due_on_1i'
    select 'July', from: 'opportunity_response_due_on_2i'
    select '4', from: 'opportunity_response_due_on_3i'
    fill_in t('admin.opportunity.description_field'), with: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.'
    select service_provider.name, from: 'Service provider'

    name_fields = find_all(:fillable_field, 'Name')
    email_fields = find_all(:fillable_field, 'Email')

    name_fields[0].set 'Jane Doe'
    email_fields[0].set 'jane.doe@example.com'
    name_fields[1].set 'Joe Bloggs'
    email_fields[1].set 'joe.bloggs@example.com'

    click_on 'Save to Draft'

    expect(page.status_code).to eq 200
    expect(page).to have_text('Saved to draft: "A chance to begin again in a golden land of opportunity and adventure"')
  end

  scenario 'Editing an opportunity' do
    val_1 = create_value(1, 'Unknown')
    val_2 = create_value(2, 'More than £1K')
    val_3 = create_value(3, 'More than £5K')
    admin = create(:admin)
    opportunity = create_opportunity(admin, status: 'pending')
    opportunity.values = [val_2]

    login_as(admin)
    visit admin_opportunities_path
    click_on opportunity.title

    expect(page.status_code).to eq 200
    expect(page).to have_text(opportunity.title)
    expect(page).to have_text('Edit opportunity')
    click_on 'Edit opportunity'

    value_field = find_by_id('opportunity_value_ids_2')
    fill_in 'Title', with: 'France desperately needs injection moulded widgets'
    fill_in t('admin.opportunity.description_field'), with: 'They can’t get enough of them.'

    expect(value_field).to_not be_nil
    expect(value_field.value).to eql('2')
    expect(value_field.checked?).to be_truthy
    click_on 'Update Opportunity'

    expect(page.status_code).to eq 200
    expect(page).to have_text('Updated opportunity "France desperately needs injection moulded widgets"')
    expect(page).to have_text('They can’t get enough of them.')
    expect(page).to have_selector(:link_or_button, 'Publish')
    click_on 'Publish'

    expect(page).to have_selector(:link_or_button, 'Unpublish')
  end

  context 'checkbox behaviour' do
    before(:each) do
      create_country('Afghanistan')
      create_country('Zambia')
      create_sector('Advertising')
      create_sector('Zookeeping')

      @admin_user = create(:admin)
      login_as(@admin_user)
    end

    context 'when editing an opportunity' do
      scenario 'selected Countries and Sectors bubble to the top of their lists' do
        existing_opportunity = create_opportunity(@admin_user)
        existing_opportunity.countries = [Country.find_by(name: 'Zambia')]
        existing_opportunity.sectors = [Sector.find_by(name: 'Zookeeping')]
        existing_opportunity.save

        visit '/admin/opportunities'

        click_on existing_opportunity.title
        click_on 'Edit opportunity'

        within(page.find('.filters-panel', text: 'Country')) do
          expect(page.first('label').text).to eq 'Zambia'
          expect(page.first('input[type=checkbox]')).to be_checked
        end

        within(page.find('.filters-panel', text: 'Sector')) do
          expect(page.first('label').text).to eq 'Zookeeping'
          expect(page.first('input[type=checkbox]')).to be_checked
        end

        uncheck 'Zambia'
        check 'Afghanistan'

        uncheck 'Zookeeping'
        check 'Advertising'

        click_on 'Update Opportunity'
        click_on 'Edit opportunity'

        within(page.find('.filters-panel', text: 'Country')) do
          expect(page.first('label').text).to eq 'Afghanistan'
          expect(page.first('input[type=checkbox]')).to be_checked
        end

        within(page.find('.filters-panel', text: 'Sector')) do
          expect(page.first('label').text).to eq 'Advertising'
          expect(page.first('input[type=checkbox]')).to be_checked
        end
      end
    end

    context 'when creating an opportunity' do
      scenario 'selected Countries and Sectors bubble to the top of their lists' do
        visit '/admin/opportunities'

        click_on 'New opportunity'
        click_on 'Create Opportunity'

        within(page.find('.filters-panel', text: 'Sector')) do
          expect(page.first('label').text).to eq 'Advertising'
          expect(page.first('input[type=checkbox]')).not_to be_checked
        end

        within(page.find('.filters-panel', text: 'Country')) do
          expect(page.first('label').text).to eq 'Afghanistan'
          expect(page.first('input[type=checkbox]')).not_to be_checked
        end

        check 'Zambia'
        check 'Zookeeping'

        click_on 'Create Opportunity'

        within(page.find('.filters-panel', text: 'Country')) do
          expect(page.first('label').text).to eq 'Zambia'
          expect(page.first('input[type=checkbox]')).to be_checked
        end

        within(page.find('.filters-panel', text: 'Sector')) do
          expect(page.first('label').text).to eq 'Zookeeping'
          expect(page.first('input[type=checkbox]')).to be_checked
        end
      end
    end

    context 'sorting behaviour' do
      scenario 'sorts the bubbled countries alphabetically' do
        opportunity = create_opportunity(@admin_user)

        opportunity.countries = [
          create_country('France'),
          create_country('Zimbabwe'),
          create_country('Mauritania'),
        ]

        opportunity.save

        visit '/admin/opportunities'
        click_on opportunity.title
        click_on 'Edit opportunity'

        within(page.find('.filters-panel', text: 'Country')) do
          expect('France').to appear_before('Mauritania')
          expect('Mauritania').to appear_before('Zimbabwe')
        end
      end
    end
  end

  context 'service provider dropdown behaviour' do
    scenario 'is not automatically populated by default' do
      uploader = create(:editor, role: :uploader)
      create(:service_provider)

      login_as(uploader)

      visit '/admin/opportunities'
      click_on 'New opportunity'
      expect(page).to have_select('opportunity[service_provider_id]')
    end

    scenario 'automatically selects the editor’s service provider if available' do
      uploader = create(:editor, role: :uploader, service_provider: create(:service_provider, name: 'Zanzibar'))

      login_as(uploader)

      visit '/admin/opportunities'
      click_on 'New opportunity'

      expect(page).to have_select('opportunity[service_provider_id]', selected: ['Zanzibar'])
    end
  end

  scenario "publishers can edit other editor's content" do
    uploader = create(:uploader)
    opportunity = create_opportunity(uploader)

    publisher = create(:publisher)
    login_as(publisher)
    visit admin_opportunities_path

    click_on opportunity.title
    click_on 'Edit opportunity'

    expect(page.status_code).to eq 200

    fill_in 'Title', with: 'A revised opportunity'
    click_on 'Update Opportunity'

    expect(page.status_code).to eq 200
    expect(page).to have_text('Updated opportunity "A revised opportunity"')
  end

  scenario "administrators can edit other editor's content" do
    uploader = create(:uploader)
    opportunity = create_opportunity(uploader)

    adminitrator = create(:admin)
    login_as(adminitrator)
    visit admin_opportunities_path

    click_on opportunity.title
    click_on 'Edit opportunity'

    expect(page.status_code).to eq 200

    fill_in 'Title', with: 'A revised opportunity'
    click_on 'Update Opportunity'

    expect(page.status_code).to eq 200
    expect(page).to have_text('Updated opportunity "A revised opportunity"')
  end

  scenario 'Providing mandatory opportunity fields when editing' do
    admin = create(:admin)
    opportunity = create_opportunity(admin)

    login_as(admin)
    visit admin_opportunities_path
    click_on opportunity.title
    click_on 'Edit opportunity'

    fill_in 'Title', with: ''
    fill_in t('admin.opportunity.teaser_field'), with: ''
    select '', from: 'opportunity_response_due_on_1i'
    select '', from: 'opportunity_response_due_on_2i'
    select '', from: 'opportunity_response_due_on_3i'
    fill_in t('admin.opportunity.description_field'), with: ''

    name_fields = find_all(:fillable_field, 'Name')
    email_fields = find_all(:fillable_field, 'Email')

    name_fields[1].set ''
    email_fields[1].set ''

    click_on 'Update Opportunity'

    expect(page.status_code).to eq 200
    expect(page).to have_text('6 errors prevented this opportunity from being saved')
    expect(page).to have_text('Title is missing')
    expect(page).to have_text("#{t('activerecord.attributes.opportunity.teaser')} is missing")
    expect(page).to have_text("#{t('activerecord.attributes.opportunity.response_due_on')} is missing")
    expect(page).to have_text('Description is missing')
    expect(page).to have_text('Contacts name is missing')
    expect(page).to have_text('Contacts email is missing')

    fill_in 'Title', with: 'Join Up now'
    fill_in t('admin.opportunity.teaser_field'), with: 'Service guarantees citizenship'
    select '2021', from: 'opportunity_response_due_on_1i'
    select 'June', from: 'opportunity_response_due_on_2i'
    select '23', from: 'opportunity_response_due_on_3i'
    fill_in t('admin.opportunity.description_field'), with: 'Young people all over the world are joining up to fight for the future'

    name_fields = find_all(:fillable_field, 'Name')
    email_fields = find_all(:fillable_field, 'Email')

    name_fields[1].set 'Juan Rico'
    email_fields[1].set 'juan@youwantoliveforever.com'

    click_on 'Update Opportunity'

    expect(page.status_code).to eq 200
    expect(page).to have_text('Updated opportunity "Join Up now"')
  end

  scenario 'editing an opportunity that has no contacts' do
    publisher = create(:publisher)
    invalid_opportunity = create(:opportunity, status: 'trash')
    invalid_opportunity.contacts.destroy_all
    invalid_opportunity.save(validate: false)

    login_as(publisher)
    visit edit_admin_opportunity_path(invalid_opportunity)
    expect(page.status_code).to eq 200

    fill_in('opportunity[contacts_attributes][0][name]', with: Faker::Name.name)
    fill_in('opportunity[contacts_attributes][0][email]', with: Faker::Internet.email)
    fill_in('opportunity[contacts_attributes][1][name]', with: Faker::Name.name)
    fill_in('opportunity[contacts_attributes][1][email]', with: Faker::Internet.email)
    click_on 'Update Opportunity'

    expect(page).to_not have_text('Contacts are missing')
  end

  scenario 'editing and updating an opportunity that has no contacts' do
    publisher = create(:publisher)
    invalid_opportunity = create(:opportunity, status: 'trash')
    invalid_opportunity.contacts.destroy_all
    invalid_opportunity.save(validate: false)

    login_as(publisher)
    visit edit_admin_opportunity_path(invalid_opportunity)
    expect(page.status_code).to eq 200

    click_on 'Update Opportunity'

    expect(page).to have_text('Contacts are missing')

    fill_in('opportunity[contacts_attributes][0][name]', with: Faker::Name.name)
    fill_in('opportunity[contacts_attributes][0][email]', with: Faker::Internet.email)
    fill_in('opportunity[contacts_attributes][1][name]', with: Faker::Name.name)
    fill_in('opportunity[contacts_attributes][1][email]', with: Faker::Internet.email)

    click_on 'Update Opportunity'

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
end
