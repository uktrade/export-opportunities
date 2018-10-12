require 'rails_helper'

feature 'Administering opportunities' do
  scenario 'Creating a new opportunity', js: true do
    country = create(:country, name: 'America')
    sector = create(:sector, name: 'Aerospace')
    type = create(:type, name: 'Public Sector')
    value = create(:value, name: 'More than £100k')
    create(:supplier_preference)
    service_provider = create(:service_provider, name: 'Italy Rome')
    uploader = create(:uploader, service_provider: service_provider)

    login_as(uploader)

    visit admin_opportunities_path
    click_on 'New opportunity'
    fill_in 'opportunity_title', with: 'A chance to begin again in a golden land of opportunity and adventure'

    select_all_buttons = find_all(:button, 'Select all')
    select_all_buttons[0].click
    select_all_buttons[1].click

    # click on type
    page.all('.field.checkbox')[0].find('input', visible: false).trigger('click')

    # click on value
    page.all('.field.radio')[0].find('input', visible: false).trigger('click')

    fill_in 'opportunity_teaser', with: 'A new life awaits you in the off-world colonies!'

    find('#opportunity_response_due_on_1i').select('2020')
    find('#opportunity_response_due_on_2i').select('12')
    find('#opportunity_response_due_on_3i').select('15')

    fill_in 'opportunity_description', with: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.'

    fill_in 'opportunity_contacts_attributes_0_name', with: 'Jane Doe'
    fill_in 'opportunity_contacts_attributes_0_email', with: 'jane.doe@example.com'
    fill_in 'opportunity_contacts_attributes_1_name', with: 'Joe Bloggs'
    fill_in 'opportunity_contacts_attributes_1_email', with: 'joe.bloggs@example.com'


    click_on 'Save and continue'

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
    expect(page).to have_text('15 Dec 2020')
    expect(page).to have_text('Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.')
    expect(page).to have_text(service_provider.name)
    expect(page).to have_text('Jane Doe <jane.doe@example.com>')
    expect(page).to have_text('Joe Bloggs <joe.bloggs@example.com>')
    expect(page).to have_text(uploader.name)
  end

  feature 'creating a new opportunity without valid data' do
    before(:each) do
      Type.delete_all
      Value.delete_all
      uploader = create(:uploader)
      country = create(:country, name: 'America')
      sector = create(:sector, name: 'Aerospace')
      type = create(:type, name: 'Public Sector', slug: 1)
      value = create(:value, name: 'More than £100k', slug: 1)
      @service_provider = create(:service_provider, name: 'Italy Rome')
      create(:supplier_preference)

      login_as(uploader)

      visit admin_opportunities_path
      click_on 'New opportunity'

      find('#opportunity_country_ids').select(country.name)
      find('#opportunity_sector_ids').select(sector.name)
    end

    scenario 'create an opportunity without valid contact details' do

      # click on type checkbox
      page.all('.field.checkbox')[0].find('input', visible: false).click

      # click on value checkbox
      page.all('.field.radio')[0].find('input', visible: false).click

      # click on supplier preference checkbox
      page.all('.field.checkbox')[1].find('input', visible: false).click

      select '2016', from: 'opportunity_response_due_on_1i'
      select '06', from: 'opportunity_response_due_on_2i'
      select '04', from: 'opportunity_response_due_on_3i'

      fill_in 'opportunity_description', with: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.'
      select @service_provider.name, from: 'Service provider'

      fill_in 'opportunity_title', with: 'A chance to begin again in a golden land of opportunity and adventure'
      fill_in 'opportunity_teaser', with: 'A new life awaits you in the off-world colonies!'

      fill_in 'opportunity_contacts_attributes_0_name', with:'Jane Doe'
      fill_in 'opportunity_contacts_attributes_0_email', with:'jane.doe.com'

      fill_in 'opportunity_contacts_attributes_1_name', with:'Joe Bloggs'
      fill_in 'opportunity_contacts_attributes_1_email', with:'joe.bloggs.com'


      click_on 'Save and continue'

      expect(page.status_code).to eq 422
      expect(page).to have_text("Contacts email doesn't look like a valid email address")
    end

    scenario 'creates a new opportunity without valid title and teaser lengths', :elasticsearch, :commit, js: true do
      # click on type checkbox
      page.all('.field.checkbox')[0].find('input', visible: false).trigger('click')

      # click on value checkbox
      page.all('.field.radio')[0].find('input', visible: false).trigger('click')

      # click on supplier preference checkbox
      page.all('.field.checkbox')[1].find('input', visible: false).trigger('click')

      select '2016', from: 'opportunity_response_due_on_1i'
      select '06', from: 'opportunity_response_due_on_2i'
      select '04', from: 'opportunity_response_due_on_3i'

      fill_in 'opportunity_description', with: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.'
      select @service_provider.name, from: 'Service provider'

      fill_in 'opportunity_contacts_attributes_0_name', with:'Jane Doe'
      fill_in 'opportunity_contacts_attributes_0_email', with:'jane@doe.com'

      fill_in 'opportunity_contacts_attributes_1_name', with:'Joe Bloggs'
      fill_in 'opportunity_contacts_attributes_1_email', with:'joe@bloggs.com'

      fill_in 'opportunity_title', with: 'Leverage agile frameworks to provide a robust synopsis for high level overviews. Iterative approaches to corporate strategy foster collaborative thinking to further the overall value proposition. Organically grow the holistic world view of disruptive253'
      fill_in 'opportunity_teaser', with: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis p153'

      click_on 'Save and continue'

      expect(page.status_code).to eq 422

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
      create(:supplier_preference)

      login_as(uploader)
      visit admin_opportunities_path

      click_on opportunity.title
      click_on 'Edit opportunity'

      fill_in 'opportunity_title', with: "Coloring book pickled fanny pack selfies blue bottle small batch palo santo jianbing marfa. Actually gastropub lomo, drinking vinegar typewriter biodiesel fashion axe kickstarter you probably haven't heard of them messenger bag echo park.1234567890 252"
      fill_in 'opportunity_teaser', with: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis p153'

      click_on 'Save and continue'
      # expect(page).to have_text("Title can\'t be more than 250")
      expect(page).to have_text("Summary can\'t be more than 140")
    end
  end

  feature 'updating ragg rating' do
    scenario 'publisher updates ragg rating to an opportunity' do
      skip('no ragg ratings anymore')
      editor = create(:publisher)
      country = create(:country, name: 'America')
      sector = create(:sector, name: 'Aerospace')
      type = create(:type, name: 'Public Sector')
      value = create(:value, name: 'More than £100k')
      service_provider = create(:service_provider, name: 'Italy Rome')
      create(:supplier_preference)
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
      skip('no ragg ratings anymore')
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
      skip('no ragg ratings anymore')
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
