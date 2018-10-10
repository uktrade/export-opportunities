require 'rails_helper'

RSpec.feature 'Commenting on opportunities' do
  scenario 'Editors can see a list of comments when viewing an opportunity' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, author: uploader)
    create(:opportunity_comment, opportunity: opportunity, message: 'Hello world!')
    login_as(uploader)

    visit '/admin/opportunities'
    click_on opportunity.title

    expect(page).to have_content 'Hello world!'
  end

  context 'Editors can add a comment to an opportunity' do
    scenario 'when viewing an opportunity' do
      uploader = create(:uploader, name: 'Barbara Windsor')
      opportunity = create(:opportunity, author: uploader)
      login_as(uploader)

      visit '/admin/opportunities'
      click_on opportunity.title

      Timecop.freeze(Time.utc(2016, 6, 23, 12, 0, 0)) do
        within '#new_opportunity_comment_form' do
          fill_in :opportunity_comment_form_message, with: 'Make comments great again!'
          click_on 'Add Comment'
        end

        expect(page).to have_content 'Make comments great again!'
        expect(page).to have_content 'Barbara Windsor (Opportunity author) on 23 June 2016 at 12:00'
      end
    end

    scenario 'when editing an opportunity' do
      uploader = create(:uploader, name: 'Barbara Windsor')
      opportunity = create(:opportunity, author: uploader)
      create(:type, name: 'Public Sector')
      create(:value, name: 'More than £100k')
      create(:supplier_preference)

      login_as(uploader)

      visit '/admin/opportunities'
      click_on opportunity.title
      click_on 'Edit opportunity'

      Timecop.freeze(Time.utc(2016, 6, 23, 12, 0, 0)) do
        within '#new_opportunity_comment_form' do
          fill_in :opportunity_comment_form_message, with: 'Make comments great again!'
          click_on 'Add Comment'
        end

        expect(page).to have_content 'Edit export opportunity'
        expect(page).to have_content 'Make comments great again!'
        expect(page).to have_content 'Barbara Windsor (Opportunity author) on 23 June 2016 at 12:00'
      end
    end
  end
end
