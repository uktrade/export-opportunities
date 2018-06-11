require 'rails_helper'

feature 'admin can view guidance page' do
  scenario 'viewing base guidance page' do
    admin = create(:admin)

    login_as(admin)
    visit admin_help_path

    expect(page).to have_content('How to write an export opportunity')
  end

  scenario 'viewing how to assess a company' do
    admin = create(:admin)

    login_as(admin)
    visit admin_help_path

    click_on 'How to assess a company'

    expect(page).to have_content('You will need to assess whether a company is both eligible and suitable for the opportunity it has applied for')
  end

  scenario 'viewing how to respond to UK companies that are Right for opportunity' do
    admin = create(:admin)

    login_as(admin)
    visit admin_help_path

    click_on 'How to respond to UK companies that are \'Right for opportunity\''
    expect(page).to have_content('Use the guidance to help you reply')
  end
end
