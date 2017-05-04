require 'rails_helper'

feature 'Reviewers can view opportunities' do
  scenario 'view opportunity list' do
    # uploader = create(:uploader)
    # country = create(:country, name: 'America')
    # sector = create(:sector, name: 'Aerospace')
    # type = create(:type, name: 'Public Sector')
    # value = create(:type, name: 'More than £100k')
    # service_provider = create(:service_provider, name: 'Italy Rome')
    #
    # login_as(uploader)
    # visit admin_opportunities_path
    # click_on 'New opportunity'
    #
    # fill_in 'Title', with: 'A chance to begin again in a golden land of opportunity and adventure'
    # check country.name
    # check sector.name
    # check type.name
    # check value.name
    # fill_in t('admin.opportunity.teaser_field'), with: 'A new life awaits you in the off-world colonies!'
    # select '2020', from: 'opportunity_response_due_on_1i'
    # select 'December', from: 'opportunity_response_due_on_2i'
    # select '4', from: 'opportunity_response_due_on_3i'
    # fill_in t('admin.opportunity.description_field'), with: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.'
    # select service_provider.name, from: 'Service provider'
    #
    # name_fields = find_all(:fillable_field, 'Name')
    # email_fields = find_all(:fillable_field, 'Email')
    #
    # name_fields[0].set 'Jane Doe'
    # email_fields[0].set 'jane.doe@example.com'
    # name_fields[1].set 'Joe Bloggs'
    # email_fields[1].set 'joe.bloggs@example.com'
    #
    # expect(page).to have_text('11 characters remaining')
    #
    # click_on 'Create Opportunity'
    #
    # expect(page.status_code).to eq 200
    # expect(page).to have_text('Created opportunity "A chance to begin again in a golden land of opportunity and adventure"')
    #
    # click_on 'A chance to begin again in a golden land of opportunity and adventure'
    #
    # expect(page).to have_text('A chance to begin again in a golden land of opportunity and adventure')
    # expect(page).to have_text('Pending')
    # expect(page).to have_text(country.name)
    # expect(page).to have_text(sector.name)
    # expect(page).to have_text(type.name)
    # expect(page).to have_text(value.name)
    # expect(page).to have_text('A new life awaits you in the off-world colonies!')
    # expect(page).to have_text('4 Dec 2020')
    # expect(page).to have_text('Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.')
    # expect(page).to have_text(service_provider.name)
    # expect(page).to have_text('Jane Doe <jane.doe@example.com>')
    # expect(page).to have_text('Joe Bloggs <joe.bloggs@example.com>')
    # expect(page).to have_text(uploader.name)
  end

  scenario 'view opportunity list with pagination' do
      fail("not implemented")
  end

  scenario 'reviewer can not create an opportunity' do
    fail("not implemented")
  end

  feature 'creating a new opportunity without valid data' do

    scenario 'creates a new opportunity without valid title and teaser lengths', js: true do

    end
  end
end
