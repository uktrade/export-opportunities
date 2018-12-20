require 'rails_helper'

feature 'Sorting opportunities', :elasticsearch, js: true do

  scenario 'by "Published date" shows most recent first' do
    create(:opportunity, :published,
            title: 'New post',
            slug: '1', 
            first_published_at: 1.months.ago,
            response_due_on:    1.months.ago + 1.year)
    create(:opportunity, :published,
            title: 'Aged post (post post), but most relevant and ending soonest',
            slug: '2', 
            first_published_at: 2.months.ago,
            response_due_on:    1.month.from_now)
    create(:opportunity, :published,
            title: 'Oldest post',
            slug: '3', 
            first_published_at: 3.months.ago,
            response_due_on:    3.months.ago + 1.year)
    sleep 1

    visit opportunities_path

    search_term = 'post'
    within '.search' do
      fill_in 's', with: search_term
      page.find('.submit').click
    end
    select('Published date', from: "sort_column_name").trigger('click')    

    expect(page).to have_current_path(
      opportunities_path(s: search_term, sort_column_name: 'first_published_at'))
    expect('New post').to appear_before('Aged post')
    expect('Aged post').to appear_before('Oldest post')
  end

  scenario 'by "Closing date" shows soonest to close first' do
    create(:opportunity, :published,
            title: 'Closes soonest',
            slug: '1', 
            first_published_at: 1.months.ago,
            response_due_on:    1.month.from_now)
    create(:opportunity, :published,
            title: 'Closes second (closes closes), but most relevant and newest',
            slug: '2', 
            first_published_at: 1.day.ago,
            response_due_on:    2.months.from_now)
    create(:opportunity, :published,
            title: 'Closes last',
            slug: '3',
            first_published_at: 1.months.ago,
            response_due_on:    3.months.from_now)
    sleep 1

    visit opportunities_path

    search_term = "Closes"
    within '.search' do
      fill_in 's', with: search_term
      page.find('.submit').click
    end
    select('Closing date', from: "sort_column_name")

    # Check select has been activated
    expect(page).to have_current_path(opportunities_path(s: search_term,
                            sort_column_name: 'response_due_on'))

    expect('Closes soonest').to appear_before('Closes second')
    expect('Closes second').to appear_before('Closes last')
  end

  # Test below is correct, but we have no application
  # code to test for relevance currently.
  # scenario 'by "Relevance" shows most relevant first' do

    # create(:opportunity, :published,
    #         title: 'Most relevant post (post post)',
    #         slug: '1', 
    #         first_published_at: 2.months.ago,
    #         response_due_on:    2.months.ago + 2.years)
    # create(:opportunity, :published,
    #         title: 'Not so relevant post (post), but newest and closes soonest',
    #         slug: '2', 
    #         first_published_at: 1.months.ago,
    #         response_due_on:    1.months.ago + 1.year)
    # create(:opportunity, :published,
    #         title: 'Least relevant',
    #         slug: '3', 
    #         first_published_at: 3.months.ago,
    #         response_due_on:    3.months.ago + 1.year)

    # sleep 1

    # visit opportunities_path

    # search_term = "post"
    # within '.search' do
    #   fill_in 's', with: search_term
    #   page.find('.submit').click
    # end

    # select('Relevance', from: "sort_column_name")
    # within '.search' do
    #   page.find('.submit').click
    # end

    # # Check select has been activated
    # expect(page).to have_current_path(opportunities_path(s: search_term,
    #                         sort_column_name: 'relevance'))

    # expect('Most relevant').to appear_before('Not so relevant')
    # expect('Not so relevant').to appear_before('Least relevant')
  # end
end