require 'rails_helper'

feature 'Sorting opportunities', :elasticsearch, js: true do
  scenario 'users can sort opportunities by first published at and expiry date' do
    create(:opportunity, :published, title: 'First Opp', first_published_at: 2.days.ago, response_due_on: 3.days.from_now)
    create(:opportunity, :published, title: 'Second Opp', first_published_at: 1.day.ago, response_due_on: 2.days.from_now)
    create(:opportunity, :published, title: 'Third Opp', first_published_at: 3.days.ago, response_due_on: 1.day.from_now)

    sleep 1
    visit '/poc/opportunities'

    # within('.search') do
      fill_in 's', with: 'Opp'
    # end
    page.find('.submit.button').click

    # within('#search-sort') do
    #   find('label[for=first_published_at]').click
    # end
    page.find('#search-sort').select('Published date')

    expect('Second').to appear_before('First')
    expect('First').to appear_before('Third')

    # within('#search-sort') do
    #   find('label[for=response_due_on]').click
    # end
    page.find('#search-sort').select('Expiry date')

    expect('Third').to appear_before('Second')
    expect('Second').to appear_before('First')
  end

  context 'when a search term is provided' do
    scenario 'users can sort opportunities by first published at, expiry date and relevance' do
      create(:opportunity, :published, title: 'Sardines, Big Sardines', first_published_at: 2.days.ago, response_due_on: 3.days.from_now)
      create(:opportunity, :published, title: 'Small Sardines', first_published_at: 1.day.ago, response_due_on: 4.days.from_now)
      create(:opportunity, :published, title: 'Really Old Sardines, Expiring Soon', first_published_at: 4.days.ago, response_due_on: 2.days.from_now)
      create(:opportunity, :published, title: 'Cod', first_published_at: 3.days.ago, response_due_on: 1.day.from_now)

      sleep 1
      visit '/poc/opportunities'

      within('.filters') do
        fill_in 's', with: 'Sardines'
        page.find('.filters__searchbutton').click
      end

      expect(page).to have_no_content('Cod')
      # expect('Sardines, Big Sardines').to appear_before('Small Sardines')

      expect(find_field('relevance', visible: false)).to be_checked

      expect(page).to have_content('Subscribe to email alerts for')

      within('.results__order') do
        find('label[for=order_published_date]').click
      end

      expect(page).to have_no_content('Cod')
      expect('Sardines, Big Sardines').to appear_before('Really Old Sardines, Expiring Soon')

      expect(find_field('published date', visible: false)).to be_checked

      expect(page).to have_content('Subscribe to email alerts for')

      within('.results__order') do
        find('label[for=order_expiry_date]').click
      end

      expect(page).to have_no_content('Cod')
      expect('Really Old Sardines, Expiring Soon').to appear_before('Sardines, Big Sardines')
      expect('Sardines, Big Sardines').to appear_before('Small Sardines')
      expect(find_field('expiry date', visible: false)).to be_checked
      expect(page).to have_content('Subscribe to email alerts for')
    end
  end
end
