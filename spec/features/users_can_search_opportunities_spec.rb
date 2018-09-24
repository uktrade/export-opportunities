require 'rails_helper'

RSpec.feature 'searching opportunities', :elasticsearch, :commit do
  scenario 'users can find an opportunity by keyword' do
    create(:opportunity, status: 'publish', title: 'Super opportunity')
    create(:opportunity, status: 'publish', title: 'Boring opportunity')

    sleep 1
    visit opportunities_path

    within '.search' do
      fill_in 's', with: 'Super'
      page.find('.submit').click
    end

    expect(page).to have_content('1 result found for Super')
    expect(page).to have_content('Super opportunity')
    expect(page).to have_no_content('Boring opportunity')
  end

  scenario 'users can find an opportunity including apostrophe' do
    create(:opportunity, status: 'publish', title: 'Children\'s opportunity')
    create(:opportunity, status: 'publish', title: 'Childrens opportunity')

    sleep 1
    visit opportunities_path

    within '.search' do
      fill_in 's', with: "Children\'s"
      page.find('.submit').click
    end

    expect(page).to have_content('2 results found')
    expect(page).to have_content("Children's opportunity")
    expect(page).to have_content('Childrens opportunity')
  end

  scenario 'users sees results that match differing stemmed versions of their keywords' do
    create(:opportunity, status: 'publish', title: 'Innovative products for fish catching')
    create(:opportunity, status: 'publish', title: 'Award-winning jam and marmalade required')

    sleep 1
    visit opportunities_path

    within '.search' do
      fill_in 's', with: 'fishing'
      page.find('.submit').click
    end

    expect(page).to have_content('Innovative products for fish catching')
    expect(page).to have_no_content('Award-winning jam and marmalade required')
  end

  scenario 'users can still find an opportunity if its content changes' do
    opportunity = create(:opportunity, status: 'publish', title: 'France requires back bacon')

    sleep 1
    visit opportunities_path

    within '.search' do
      fill_in 's', with: 'bacon'
      page.find('.submit').click
    end

    expect(page).to have_content('France requires back bacon')
    expect(page).to have_no_content('France requires pork sausages')

    opportunity.update_column(:title, 'France requires pork sausages')
    opportunity.save!
    Opportunity.__elasticsearch__.refresh_index!

    within '.search' do
      fill_in 's', with: 'pork'
      page.find('.submit').click
    end

    expect(page).to have_content('France requires pork sausages')
    expect(page).to have_no_content('France requires back bacon')
  end

  scenario 'users cannot perform an empty search from home page', js: true do
    visit root_path
    sleep 1


    # Check we're on home and have no error showing.
    expect(page).to have_content('Find export opportunities')
    expect(page).to have_no_content('Please type in a product or service and/or select a region or country')

    # Form each search form...
    page.all('.search-form').each do |form|
      form.find('.submit').click
      sleep 1

      # Check we stay on home and have the error in content.
      expect(page).to have_content('Find export opportunities')
      expect(page).to have_content('Please type in a product or service and/or select a region or country')
    end
  end

  scenario 'users cannot perform an empty search from search results page', js: true do
    visit opportunities_path
    sleep 1

    # Check we're on search results page.
    expect(current_page).to eql('Search results')

    within '.search' do
      find('.submit').click
    end
    sleep 1

    # Check we are still on search results page but error does not show.
    expect(current_page).to eql('Search results')
    expect(page).to have_no_content('Please type in a product or service and/or select a region or country')
  end

  def current_page
    page.find('.breadcrumbs').find('.current').text
  end
end
