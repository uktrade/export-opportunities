require 'rails_helper'

feature 'Sorting opportunities', :elasticsearch, js: true do
  scenario 'users can sort opportunities by first published at and expiry date' do
    create(:opportunity, :published, title: 'First Opp', first_published_at: 2.days.ago, response_due_on: 3.days.from_now)
    create(:opportunity, :published, title: 'Second Opp', first_published_at: 1.day.ago, response_due_on: 2.days.from_now)
    create(:opportunity, :published, title: 'Third Opp', first_published_at: 3.days.ago, response_due_on: 1.day.from_now)

    sleep 1
    visit opportunities_path

    within('.search') do
      fill_in 's', with: 'Opp'
      page.find('.submit').click
    end

    # sort by published date
    page.find('#search-sort').select('Published date')
    page.find('.button.submit').click

    expect('Second').to appear_before('First')
    expect('First').to appear_before('Third')

    # sort by expiry date
    page.find('#search-sort').select('Expiry date')
    page.find('.button.submit').click

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
      visit opportunities_path

      within('.search') do
        fill_in 's', with: 'Sardines'
        page.find('.submit').click
      end
      
      expect(page).to have_no_content('Cod')

      page.find('#search-sort').select('Published date')
      page.find('.button.submit').click

      expect(page).to have_no_content('Cod')
      expect('Sardines, Big Sardines').to appear_before('Really Old Sardines, Expiring Soon')

      page.find('#search-sort').select('Expiry date')
      page.find('.button.submit').click

      expect(page).to have_no_content('Cod')
      expect('Really Old Sardines, Expiring Soon').to appear_before('Sardines, Big Sardines')
      expect('Sardines, Big Sardines').to appear_before('Small Sardines')
    end
  end
end
