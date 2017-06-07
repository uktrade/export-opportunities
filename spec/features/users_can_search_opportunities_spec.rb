require 'rails_helper'

RSpec.feature 'searching opportunities', :elasticsearch, :commit do
  scenario 'users can find an opportunity by keyword' do
    create(:opportunity, status: 'publish', title: 'Super opportunity')
    create(:opportunity, status: 'publish', title: 'Boring opportunity')

    sleep 1
    visit opportunities_path

    expect(page).to have_content('What product or service are you selling?')

    within '#search-form' do
      fill_in 's', with: 'Super'
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content('Super opportunity')
    expect(page).to have_no_content('Boring opportunity')
  end

  scenario 'users sees results that match differing stemmed versions of their keywords' do
    create(:opportunity, status: 'publish', title: 'Innovative products for fish catching')
    create(:opportunity, status: 'publish', title: 'Award-winning jam and marmalade required')

    sleep 1
    visit opportunities_path

    within '#search-form' do
      fill_in 's', with: 'fishing'
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content('Innovative products for fish catching')
    expect(page).to have_no_content('Award-winning jam and marmalade required')
  end

  scenario 'users can still find an opportunity if its content changes' do
    opportunity = create(:opportunity, status: 'publish', title: 'France requires back bacon')

    sleep 1
    visit opportunities_path

    within '#search-form' do
      fill_in 's', with: 'bacon'
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content('France requires back bacon')
    expect(page).to have_no_content('France requires pork sausages')

    opportunity.update_column(:title, 'France requires pork sausages')
    opportunity.save!
    Opportunity.__elasticsearch__.refresh_index!

    within '#search-form' do
      fill_in 's', with: 'pork'
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content('France requires pork sausages')
    expect(page).to have_no_content('France requires back bacon')
  end
end
