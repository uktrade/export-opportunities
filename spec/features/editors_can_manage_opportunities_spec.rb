require 'rails_helper'

feature 'Administering opportunities' do
  scenario 'Creating a new opportunity', js: true do
    uploader = create(:uploader)
    country = create(:country, name: 'America')
    sector = create(:sector, name: 'Aerospace')
    type = create(:type, name: 'Public Sector')
    value = create(:type, name: 'More than £100k')
    service_provider = create(:service_provider, name: 'Italy Rome')

    login_as(uploader)
    visit admin_opportunities_path
    click_on 'New opportunity'

    fill_in 'Title', with: 'A chance to begin again in a golden land of opportunity and adventure'
    check country.name
    check sector.name
    check type.name
    check value.name
    fill_in t('admin.opportunity.teaser_field'), with: 'A new life awaits you in the off-world colonies!'
    select '2020', from: 'opportunity_response_due_on_1i'
    select 'December', from: 'opportunity_response_due_on_2i'
    select '4', from: 'opportunity_response_due_on_3i'
    fill_in t('admin.opportunity.description_field'), with: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.'
    select service_provider.name, from: 'Service provider'

    name_fields = find_all(:fillable_field, 'Name')
    email_fields = find_all(:fillable_field, 'Email')

    name_fields[0].set 'Jane Doe'
    email_fields[0].set 'jane.doe@example.com'
    name_fields[1].set 'Joe Bloggs'
    email_fields[1].set 'joe.bloggs@example.com'

    expect(page).to have_text('11 characters remaining')

    click_on 'Create Opportunity'

    expect(page.status_code).to eq 200
    expect(page).to have_text('Created opportunity "A chance to begin again in a golden land of opportunity and adventure"')

    click_on 'A chance to begin again in a golden land of opportunity and adventure'

    expect(page).to have_text('A chance to begin again in a golden land of opportunity and adventure')
    expect(page).to have_text('Pending')
    expect(page).to have_text(country.name)
    expect(page).to have_text(sector.name)
    expect(page).to have_text(type.name)
    expect(page).to have_text(value.name)
    expect(page).to have_text('A new life awaits you in the off-world colonies!')
    expect(page).to have_text('4 Dec 2020')
    expect(page).to have_text('Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.')
    expect(page).to have_text(service_provider.name)
    expect(page).to have_text('Jane Doe <jane.doe@example.com>')
    expect(page).to have_text('Joe Bloggs <joe.bloggs@example.com>')
    expect(page).to have_text(uploader.name)
  end

  feature 'creating a new opportunity without valid data' do
    before(:each) do
      uploader = create(:uploader)
      country = create(:country, name: 'America')
      sector = create(:sector, name: 'Aerospace')
      type = create(:type, name: 'Public Sector')
      value = create(:type, name: 'More than £100k')
      service_provider = create(:service_provider, name: 'Italy Rome')

      login_as(uploader)
      visit admin_opportunities_path
      click_on 'New opportunity'

      check country.name
      check sector.name
      check type.name
      check value.name
      select '2016', from: 'opportunity_response_due_on_1i'
      select 'June', from: 'opportunity_response_due_on_2i'
      select '4', from: 'opportunity_response_due_on_3i'
      fill_in t('admin.opportunity.description_field'), with: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.'
      select service_provider.name, from: 'Service provider'
    end

    scenario 'create an opportunity without valid contact details' do
      fill_in 'Title', with: 'A chance to begin again in a golden land of opportunity and adventure'
      fill_in t('admin.opportunity.teaser_field'), with: 'A new life awaits you in the off-world colonies!'

      name_fields = find_all(:fillable_field, 'Name')
      email_fields = find_all(:fillable_field, 'Email')

      name_fields[0].set 'Jane Doe'
      email_fields[0].set 'jane.doe.com'
      name_fields[1].set 'Joe Bloggs'
      email_fields[1].set 'joe.bloggs.com'

      click_on 'Create Opportunity'

      expect(page.status_code).to eq 422
      expect(page).to have_text("Contacts email doesn't look like a valid email address")
    end

    scenario 'creates a new opportunity without valid title and teaser lengths', js: true do
      name_fields = find_all(:fillable_field, 'Name')
      email_fields = find_all(:fillable_field, 'Email')

      name_fields[0].set 'Jane Doe'
      email_fields[0].set 'jane@doe.com'
      name_fields[1].set 'Joe Bloggs'
      email_fields[1].set 'joe@bloggs.com'

      fill_in 'Title', with: 'A creative man is motivated by the desire to achieve, not by the desire to beat others90'
      fill_in t('admin.opportunity.teaser_field'), with: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis p153'

      expect(page).to have_text('8 characters over the limit')

      click_on 'Create Opportunity'

      expect(page.status_code).to eq 422
      expect(page).to have_text("Title can\'t be more than 80")
      expect(page).to have_text("Summary can\'t be more than 140")
    end
  end
  feature 'updating an opportunity' do
    scenario 'updates an opportunity to invalid title and teaser lengths' do
      uploader = create(:uploader)
      create(:country, name: 'America')
      create(:sector, name: 'Aerospace')
      create(:type, name: 'Public Sector')
      create(:type, name: 'More than £100k')
      create(:service_provider, name: 'Italy Rome')
      opportunity = create(:opportunity, status: :pending, title: 'test title', teaser: 'teaser teasing teaser', author: uploader)

      login_as(uploader)
      visit admin_opportunities_path

      click_on opportunity.title
      click_on 'Edit opportunity'

      fill_in 'opportunity_title', with: 'A creative man is motivated by the desire to achieve, not by the desire to beat others90'
      fill_in 'opportunity_teaser', with: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis p153'

      click_on 'Update Opportunity'
      expect(page).to have_text("Title can\'t be more than 80")
      expect(page).to have_text("Summary can\'t be more than 140")
    end
  end
end
