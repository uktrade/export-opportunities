require 'rails_helper'

feature 'users can provide customer satisfaction feedback' do
  context 'when submitting the form' do 
    before do 
      user = create(:user, email: 'bob@smith.com')
      sector = create(:sector, name: 'Aerospace')
      opportunity = create(:opportunity, :published, title: 'Hello World', slug: 'hello-world')
  
      login_as(user, scope: :user)

      visit '/export-opportunities/'
      click_on opportunity.title
  
      click_on 'Express your interest'
  
      fill_in 'First name', with: Faker::Name.first_name
      fill_in 'Last name', with: Faker::Name.last_name
      fill_in 'Business name', with: 'DBT'
      fill_in 'Address', with: Faker::Address.street_address
      fill_in 'Post code', with: Faker::Address.postcode
  
      select sector.name, from: 'enquiry_company_sector'
      select 'Yes, 1-2 years ago', from: 'enquiry_existing_exporter'
  
      fill_in 'enquiry_company_explanation', with: 'Blah blah blah'
  
      click_on 'Submit'
    end

    scenario 'successfully submitting the customer satisfaction form' do  
      choose 'Satisfied'
  
      click_on 'Submit and continue'
      expect(page.body).to have_content('Thank you for submitting your rating')
  
      click_on 'Submit feedback'
      expect(page.body).to have_content('Thank you for helping us to improve this service')
    end

    scenario 'unsuccessfully submitting the customer satisfaction form' do  
      click_on 'Submit and continue'
      expect(page.body).to have_content('Satisfaction rating is missing')
    end
  end
end