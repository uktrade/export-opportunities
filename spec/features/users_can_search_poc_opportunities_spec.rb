require 'rails_helper'

RSpec.feature 'searching opportunities', :elasticsearch, :commit do
  scenario 'users can find an opportunity by keyword' do
    skip('TODO: fix')
    create(:opportunity, status: 'publish', title: 'Super opportunity')
    create(:opportunity, status: 'publish', title: 'Boring opportunity')

    sleep 1
    visit poc_opportunities_path

    expect(page).to have_content('Search for opportunitities and pitch your company to overseas buyers who are looking for products and services like yours')

    within '.opportunities-search-form' do
      fill_in 's', with: 'Super'
      page.find('.button.submit').click
    end

    expect(page).to have_content('Super opportunity')
    expect(page).to have_no_content('Boring opportunity')
  end

  scenario 'users can find an opportunity including apostroph\'s ' do
    skip('TODO: fix')
    create(:opportunity, status: 'publish', title: 'Children\'s opportunity')
    create(:opportunity, status: 'publish', title: 'Childrens opportunity')

    sleep 1
    visit poc_opportunities_path

    expect(page).to have_content('Product or service keyword')

    within '.opportunities-search-form' do
      fill_in 's', with: "Children\'s"
      page.find('.button.submit').click
    end

    expect(page).to have_content("Children's opportunity")
    expect(page).to have_content('Childrens opportunity')
  end

  scenario 'users sees results that match differing stemmed versions of their keywords' do
    skip('TODO: fix')
    create(:opportunity, status: 'publish', title: 'Innovative products for fish catching')
    create(:opportunity, status: 'publish', title: 'Award-winning jam and marmalade required')

    sleep 1
    visit poc_opportunities_path

    within '.opportunities-search-form' do
      fill_in 's', with: 'fishing'
      page.find('.button.submit').click
    end

    expect(page).to have_content('Innovative products for fish catching')
    expect(page).to have_no_content('Award-winning jam and marmalade required')
  end

  scenario 'users can still find an opportunity if its content changes' do
    skip('TODO: fix')
    opportunity = create(:opportunity, status: 'publish', title: 'France requires back bacon')

    sleep 1
    visit poc_opportunities_path

    within '.opportunities-search-form' do
      fill_in 's', with: 'bacon'
      page.find('.button.submit').click
    end

    expect(page).to have_content('France requires back bacon')
    expect(page).to have_no_content('France requires pork sausages')

    opportunity.update_column(:title, 'France requires pork sausages')
    opportunity.save!
    Opportunity.__elasticsearch__.refresh_index!

    within '.opportunities-search-form' do
      fill_in 's', with: 'pork'
      page.find('.button.submit').click
    end

    expect(page).to have_content('France requires pork sausages')
    expect(page).to have_no_content('France requires back bacon')
  end
end
