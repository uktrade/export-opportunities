require 'rails_helper'

feature 'Sorting opportunities', :elasticsearch, js: true do

  scenario 'by "Published date" shows most recent first' do
    create(:opportunity, :published,
            title: 'New post',
            first_published_at: 1.months.ago,
            response_due_on:    1.months.ago + 1.year)
    create(:opportunity, :published,
            title: 'Old post, but ending soonest',
            first_published_at: 2.months.ago,
            response_due_on:    1.month.from_now)
    create(:opportunity, :published,
            title: 'Oldest post',
            first_published_at: 3.months.ago,
            response_due_on:    3.months.ago + 1.year)
    refresh_elasticsearch

    visit opportunities_path

    search_term = 'post'
    within '.search' do
      fill_in 's', with: search_term
      page.find('.submit').click
    end
    select('Published date', from: "sort_column_name_visible").trigger('click')    

    expect(page).to have_current_path(
      opportunities_path(s: search_term, sort_column_name: 'first_published_at'))
    expect('New post').to appear_before('Old post')
    expect('Old post').to appear_before('Oldest post')
  end

  scenario 'by "Closing date" shows soonest to close first' do
    create(:opportunity, :published,
            title: 'Closes soonest',
            first_published_at: 1.months.ago,
            response_due_on:    1.month.from_now)
    create(:opportunity, :published,
            title: 'Closes second, but newest',
            first_published_at: 1.day.ago,
            response_due_on:    2.months.from_now)
    create(:opportunity, :published,
            title: 'Closes last',
            first_published_at: 1.months.ago,
            response_due_on:    3.months.from_now)
    refresh_elasticsearch

    visit opportunities_path

    search_term = "Closes"
    within '.search' do
      fill_in 's', with: search_term
      page.find('.submit').click
    end
    select('Closing date', from: "sort_column_name_visible").trigger('click')

    # Check select has been activated
    expect(page).to have_current_path(opportunities_path(s: search_term,
                            sort_column_name: 'response_due_on'))

    expect('Closes soonest').to appear_before('Closes second')
    expect('Closes second').to appear_before('Closes last')
  end
end