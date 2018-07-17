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

    expect(page).to have_text('181 characters remaining')

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

      fill_in 'Title', with: 'Leverage agile frameworks to provide a robust synopsis for high level overviews. Iterative approaches to corporate strategy foster collaborative thinking to further the overall value proposition. Organically grow the holistic world view of disruptive253'
      fill_in t('admin.opportunity.teaser_field'), with: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis p153'

      expect(page).to have_text('3 characters over the limit')

      click_on 'Create Opportunity'

      expect(page.status_code).to eq 422
      expect(page).to have_text("Title can\'t be more than 250")
      expect(page).to have_text("be 140 characters or fewer")
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

      fill_in 'opportunity_title', with: "Coloring book pickled fanny pack selfies blue bottle small batch palo santo jianbing marfa. Actually gastropub lomo, drinking vinegar typewriter biodiesel fashion axe kickstarter you probably haven't heard of them messenger bag echo park.1234567890 252"
      fill_in 'opportunity_teaser', with: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis p153'

      click_on 'Update Opportunity'
      expect(page).to have_text("Title can\'t be more than 250")
      expect(page).to have_text("Summary can\'t be more than 140")
    end
  end

  feature 'updating ragg rating' do
    scenario 'publisher updates ragg rating to an opportunity' do
      editor = create(:publisher)
      opportunity = create(:opportunity, status: :pending)

      login_as(editor)
      visit admin_opportunities_path

      click_on opportunity.title
      click_on 'Edit opportunity'
      choose 'radio-inline-2' # amber
      click_on 'Update Opportunity'

      within(:css, 'table td.ragg-cell') do
        expect(page).to have_text('amber')
      end
    end

    scenario 'admin sets ragg rating to trash, ragg rating should be deleted' do
      admin = create(:admin)
      opportunity = create(:opportunity, :ragg_red, status: :pending)

      login_as(admin)
      visit admin_opportunities_path

      click_on opportunity.title

      expect(page).to have_text('red')

      click_on 'Trash'

      within(:css, 'table td.ragg-cell') do
        expect(page).to_not have_text('red')
      end
    end

    scenario 'admin sets ragg rating to draft, ragg rating should not be deleted' do
      admin = create(:admin)
      opportunity = create(:opportunity, :ragg_red, status: :pending)

      login_as(admin)
      visit admin_opportunities_path

      click_on opportunity.title

      within(:css, 'table td.ragg-cell') do
        expect(page).to have_text('red')
      end

      click_on 'Draft'

      within(:css, 'table td.ragg-cell') do
        expect(page).to have_text('red')
      end
    end

    feature 'managing spelling and sensitivity errors in opportunities' do
      scenario 'published opportunity with a spelling error, error should be highlighted with the correct alignment in *red* font' do
        admin = create(:admin)
        opportunity = create(:opportunity, status: :publish, title: 'A sample title', slug: 'spelling-bee-contest')
        opportunity_check = OpportunityCheck.new
        opportunity_check.submitted_text = "A sample title permeate should not be spelled as permeat. This is a difficult word to spell"
        opportunity_check.offensive_term = "permeat"
        opportunity_check.suggested_term = "permeate"
        opportunity_check.score = 94
        opportunity_check.offset = 50
        opportunity_check.length = 7
        opportunity_check.opportunity_id = opportunity.id

        opportunity_check.save!

        login_as(admin)
        visit admin_opportunities_path

        click_on opportunity.title

        expect(page.body).to have_content('permeat. This is a difficult word to spell')
      end
    end
  end
end
