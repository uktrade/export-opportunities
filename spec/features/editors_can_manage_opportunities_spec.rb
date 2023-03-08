# coding: utf-8
require 'rails_helper'

feature 'Administering opportunities' do
  before(:all) do
    @content = get_content('admin/opportunities')
  end

  scenario 'Creating a new opportunity', js: true do
    type = create(:type, name: 'Public Sector')
    value = create(:value, name: 'More than £100k')
    country = create(:country, name: 'America')
    sector = create(:sector, name: 'Aerospace')
    supplier_preference = create(:supplier_preference)
    service_provider = create(:service_provider, name: 'Italy Rome')
    uploader = create(:uploader, service_provider: service_provider)

    login_as(uploader)
    visit admin_opportunities_path

    # Create opportunity
    click_on 'New opportunity'

    fill_in 'opportunity_title', with: 'Lorem ipsum title'
    fill_in 'opportunity_teaser', with: 'Lorem ipsum teaser'
    fill_in 'opportunity_description', with: 'Lorem ipsum description'
    fill_in 'opportunity_contacts_attributes_0_name', with: uploader.name
    fill_in 'opportunity_contacts_attributes_0_email', with: 'jane.doe@example.com'
    fill_in 'opportunity_contacts_attributes_1_name', with: 'Joe Bloggs'
    fill_in 'opportunity_contacts_attributes_1_email', with: 'joe.bloggs@example.com'

    find_by_id("opportunity_value_ids_#{value.id}", visible: false).trigger('click')
    find_by_id("opportunity_type_ids_#{type.id}", visible: false).trigger('click')

    select country.name, from: 'opportunity[country_ids][]', visible: false
    select sector.name, from: 'opportunity[sector_ids][]', visible: false
    select service_provider.name, from: 'opportunity[service_provider_id]'
    select '2020', from: 'opportunity_response_due_on_1i'
    select '12', from: 'opportunity_response_due_on_2i'
    select '15', from: 'opportunity_response_due_on_3i'

    click_on 'Save and continue'

    expect(page.status_code).to eq 200
    expect(page).to have_text('Created opportunity "Lorem ipsum title"')

    # View should be admin/opportunity#show of created opportunity
    expect(page).to have_text('Lorem ipsum title')
    expect(page).to have_text('Lorem ipsum teaser')
    expect(page).to have_text(/Lorem ipsum description/)
    expect(page).to have_text('Pending')
    expect(page).to have_text(country.name)
    expect(page).to have_text(sector.name)
    expect(page).to have_text(type.name)
    expect(page).to have_text(value.name)
    expect(page).to have_text('15 Dec 2020')
    expect(page).to have_text(service_provider.name)
    expect(page).to have_text(uploader.name)
    expect(page).to have_text("#{uploader.name} <jane.doe@example.com>")
    expect(page).to have_text('Joe Bloggs')
    expect(page).to have_text('Joe Bloggs <joe.bloggs@example.com>')
  end

  scenario 'creates a new opportunity with invalid nbsp characters', :elasticsearch, :commit, js: true do
    type = create(:type, name: 'Public Sector')
    value = create(:value, name: 'More than £100k')
    country = create(:country, name: 'America')
    sector = create(:sector, name: 'Aerospace')
    supplier_preference = create(:supplier_preference)
    service_provider = create(:service_provider, name: 'Italy Rome')
    uploader = create(:uploader, service_provider: service_provider)

    login_as(uploader)
    visit admin_opportunities_path

    # Create opportunity
    click_on 'New opportunity'

    fill_in 'opportunity_title', with: 'Lorem ipsum title'
    fill_in 'opportunity_teaser', with: 'Lorem ipsum teaser'
    fill_in 'opportunity_description', with: 'Lorem&nbsp;ipsum description'
    fill_in 'opportunity_contacts_attributes_0_name', with: uploader.name
    fill_in 'opportunity_contacts_attributes_0_email', with: 'jane.doe@example.com'
    fill_in 'opportunity_contacts_attributes_1_name', with: 'Joe Bloggs'
    fill_in 'opportunity_contacts_attributes_1_email', with: 'joe.bloggs@example.com'

    find_by_id("opportunity_value_ids_#{value.id}", visible: false).trigger('click')
    find_by_id("opportunity_type_ids_#{type.id}", visible: false).trigger('click')

    select country.name, from: 'opportunity[country_ids][]', visible: false
    select sector.name, from: 'opportunity[sector_ids][]', visible: false
    select service_provider.name, from: 'opportunity[service_provider_id]'
    select '2020', from: 'opportunity_response_due_on_1i'
    select '12', from: 'opportunity_response_due_on_2i'
    select '15', from: 'opportunity_response_due_on_3i'

    click_on 'Save and continue'

    expect(page.status_code).to eq 200
    expect(page).to have_text(/Lorem ipsum description/)
  end

  feature 'creating a new opportunity without valid data', js: true do
    before(:each) do
      Type.delete_all
      Value.delete_all
      Country.delete_all
      Sector.delete_all
      SupplierPreference.delete_all
      ServiceProvider.delete_all
      type = create(:type, name: 'Public Sector', id: 9)
      value = create(:value, name: 'More than £100k', id: 9)
      country = create(:country, name: 'America')
      sector = create(:sector, name: 'Aerospace')
      supplier_preference = create(:supplier_preference)
      service_provider = create(:service_provider, name: 'Italy Rome')
      uploader = create(:uploader)

      login_as(uploader)

      visit admin_opportunities_path
      click_on 'New opportunity'

      select country.name, from: 'opportunity[country_ids][]', visible: false
      select sector.name, from: 'opportunity[sector_ids][]', visible: false
      select service_provider.name, from: 'opportunity[service_provider_id]'
      select '2016', from: 'opportunity_response_due_on_1i'
      select '06', from: 'opportunity_response_due_on_2i'
      select '04', from: 'opportunity_response_due_on_3i'

      find_by_id('opportunity_value_ids_9', visible: false).trigger('click')
      find_by_id('opportunity_type_ids_9', visible: false).trigger('click')
    end

    scenario 'create an opportunity without valid contact details' do
      fill_in 'opportunity_title', with: 'Lorem ipsum title'
      fill_in 'opportunity_teaser', with: 'Lorem ipsum teaser'
      fill_in 'opportunity_description', with: 'Lorem ipsum description'
      fill_in 'opportunity_contacts_attributes_0_name', with: 'Jane Doe'
      fill_in 'opportunity_contacts_attributes_0_email', with: 'jane.doe.com'
      fill_in 'opportunity_contacts_attributes_1_name', with: 'Joe Bloggs'
      fill_in 'opportunity_contacts_attributes_1_email', with: 'joe.bloggs.com'

      click_on 'Save and continue'

      expect(page.status_code).to eq 422
      expect(page).to have_text("Contacts email doesn't look like a valid email address")
    end

    scenario 'creates a new opportunity without valid title and teaser lengths', :elasticsearch, :commit, js: true do
      fill_in 'opportunity_title', with: 'Lorem ipsum title'
      fill_in 'opportunity_description', with: 'Lorem ipsum description'
      fill_in 'opportunity_contacts_attributes_0_name', with: 'Jane Doe'
      fill_in 'opportunity_contacts_attributes_0_email', with: 'jane.doe.com'
      fill_in 'opportunity_contacts_attributes_1_name', with: 'Joe Bloggs'
      fill_in 'opportunity_contacts_attributes_1_email', with: 'joe.bloggs.com'

      fill_in 'opportunity_teaser', with: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis p153'

      click_on 'Save and continue'

      expect(page.status_code).to eq 422
      expect(page).to have_text("Summary can\'t be more than 140")
    end
  end

  feature 'updating an opportunity' do
    scenario 'updates an opportunity to invalid teaser length' do
      uploader = create(:uploader)
      type = create(:type, name: 'Public Sector')
      value = create(:value, name: 'More than £100k')
      supplier_preference = create(:supplier_preference)
      create(:country, name: 'America')
      create(:sector, name: 'Aerospace')
      create(:service_provider, name: 'Italy Rome')
      opportunity = create(:opportunity, status: :pending, title: 'test title', teaser: 'teaser teasing teaser', author: uploader)

      login_as(uploader)
      visit admin_opportunities_path

      click_on opportunity.title
      click_on 'Edit opportunity'

      fill_in 'opportunity_teaser', with: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis p153'

      click_on 'Save and continue'
      expect(page).to have_text("Summary can\'t be more than 140")
    end

    scenario 'updates a duplicate slug opportunity ending in -133 (3 digits), should not change the random id appended to slug' do
      administrator = create(:admin)
      type = create(:type, name: 'Public Sector')
      value = create(:value, name: 'More than £100k')
      supplier_preference = create(:supplier_preference)
      create(:country, name: 'America')
      create(:sector, name: 'Aerospace')
      create(:service_provider, name: 'Italy Rome')
      opportunity = create(:opportunity, status: :publish, title: 'export opportunities', teaser: 'teaser teasing teaser', author: administrator, slug: 'export-opportunities-133')

      login_as(administrator)
      visit admin_opportunities_path

      click_on opportunity.title
      click_on 'Edit opportunity'

      fill_in 'opportunity_teaser', with: 'you can update the teaser, but you cant update the slug now!'
      click_on 'Save and continue'

      expect(page).to have_current_path(admin_opportunity_url(opportunity), url: true)
      expect(page).to have_text(opportunity.title)
      expect(current_path).to eq('/export-opportunities/admin/opportunities/export-opportunities-133')
    end

    scenario 'updates a duplicate slug opportunity ending in -3 (1 digit), should not change the random id appended to slug' do
      administrator = create(:admin)
      type = create(:type, name: 'Public Sector')
      value = create(:value, name: 'More than £100k')
      supplier_preference = create(:supplier_preference)
      create(:country, name: 'America')
      create(:sector, name: 'Aerospace')
      create(:service_provider, name: 'Italy Rome')
      opportunity = create(:opportunity, status: :publish, title: 'export opportunities', teaser: 'teaser teasing teaser', author: administrator, slug: 'export-opportunities-3')

      login_as(administrator)
      visit admin_opportunities_path

      click_on opportunity.title
      click_on 'Edit opportunity'

      fill_in 'opportunity_teaser', with: 'you can update the teaser, but you cant update the slug now!'
      click_on 'Save and continue'

      expect(page).to have_current_path(admin_opportunity_url(opportunity), url: true)
      expect(page).to have_text(opportunity.title)
    end

    scenario 'updates the cpv code, should fetch from service and store the new code correctly' do
      administrator = create(:admin)
      type = create(:type, name: 'Public Sector')
      value = create(:value, name: 'More than £100k')
      supplier_preference = create(:supplier_preference)
      create(:country, name: 'America')
      create(:sector, name: 'Aerospace')
      create(:service_provider, name: 'Italy Rome')
      opportunity = create(:opportunity, status: :publish, title: 'export opportunities', teaser: 'teaser teasing teaser', author: administrator, slug: 'export-opportunities-3')
      opportunity_cpv = create(:opportunity_cpv, opportunity: opportunity, industry_id: 75211200)

      login_as(administrator)
      visit admin_opportunities_path

      click_on opportunity.title
      click_on 'Edit opportunity'

      expect(page.body).to include(opportunity_cpv.industry_id)
    end
  end

  feature 'updating ragg rating' do
    scenario 'publisher updates ragg rating to an opportunity' do
      editor = create(:publisher)
      type = create(:type, name: 'Public Sector')
      value = create(:value, name: 'More than £100k')
      supplier_preference = create(:supplier_preference)
      create(:country, name: 'America')
      create(:sector, name: 'Aerospace')
      create(:service_provider, name: 'Italy Rome')
      opportunity = create(:opportunity, status: :pending)


      login_as(editor)
      visit admin_opportunities_path

      click_on opportunity.title
      click_on 'Edit opportunity'

      choose 'opportunity_ragg_amber'
      click_on @content['submit_create']

      expect(page.find('.ragg')).to have_text('amber')
    end

    scenario 'admin sets ragg rating to trash, ragg rating should be deleted' do
      admin = create(:admin)
      opportunity = create(:opportunity, :ragg_red, status: :pending)

      login_as(admin)
      visit admin_opportunities_path

      click_on opportunity.title

      expect(page).to have_text('red')

      click_on 'Trash'

      expect(page.find('.ragg')).to_not have_text('red')
    end

    scenario 'admin sets ragg rating to draft, ragg rating should not be deleted' do
      admin = create(:admin)
      opportunity = create(:opportunity, :ragg_red, status: :pending)

      login_as(admin)
      visit admin_opportunities_path

      click_on opportunity.title

      expect(page.find('.ragg')).to have_text('red')

      click_on 'Draft'

      expect(page.find('.ragg')).to have_text('red')
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

    feature 'managing BST errors in opportunities' do
      scenario 'published opportunity with a BST error coming from internal list' do
        admin = create(:admin)
        opportunity = create(:opportunity, status: :publish, title: 'A sample title', slug: 'swearing-contest')
        opportunity_sensitivity_check = OpportunitySensitivityCheck.new
        opportunity_sensitivity_check.submitted_text = "A sample title permeate should not be spelled as permeat. This is a difficult word to spell"
        opportunity_sensitivity_check.review_recommended = true
        opportunity_sensitivity_check.category1_score = 0.009
        opportunity_sensitivity_check.category2_score = 0.010
        opportunity_sensitivity_check.category3_score = 0.011
        opportunity_sensitivity_check.opportunity_id = opportunity.id

        opportunity_sensitivity_check.save!

        opportunity_sensitivity_term_check = OpportunitySensitivityTermCheck.new
        opportunity_sensitivity_term_check.opportunity_sensitivity_check_id = opportunity_sensitivity_check.id
        opportunity_sensitivity_term_check.list_id = 0
        opportunity_sensitivity_term_check.term = 'Gooogle'
        opportunity_sensitivity_term_check.save!

        login_as(admin)
        visit admin_opportunities_path

        click_on opportunity.title

        expect(page.body).to have_content('Gooogle')
        expect(page.body).to have_content('Azure internal list')
      end

      scenario 'published opportunity with a BST error coming from DBT list' do
        admin = create(:admin)
        opportunity = create(:opportunity, status: :publish, title: 'A sample title', slug: 'swearing-contest')
        opportunity_sensitivity_check = OpportunitySensitivityCheck.new
        opportunity_sensitivity_check.submitted_text = "A sample title permeate should not be spelled as permeat. This is a difficult word to spell"
        opportunity_sensitivity_check.review_recommended = true
        opportunity_sensitivity_check.category1_score = 0.009
        opportunity_sensitivity_check.category2_score = 0.010
        opportunity_sensitivity_check.category3_score = 0.011
        opportunity_sensitivity_check.opportunity_id = opportunity.id

        opportunity_sensitivity_check.save!

        opportunity_sensitivity_term_check = OpportunitySensitivityTermCheck.new
        opportunity_sensitivity_term_check.opportunity_sensitivity_check_id = opportunity_sensitivity_check.id
        opportunity_sensitivity_term_check.list_id = 151
        opportunity_sensitivity_term_check.term = 'innovative jam'
        opportunity_sensitivity_term_check.save!

        login_as(admin)
        visit admin_opportunities_path

        click_on opportunity.title

        expect(page.body).to have_content('innovative jam')
        expect(page.body).to have_content('DBT list')
      end
    end
  end
end
