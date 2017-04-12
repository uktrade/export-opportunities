require 'rails_helper'

feature 'Searching opportunities' do
  scenario 'search by keyword' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, author: uploader, title: 'Bacon and eggs')
    irrelevant_opportunity = create(:opportunity, title: 'Cheese and onions')

    login_as(uploader)
    visit admin_opportunities_path
    fill_in 's', with: 'bacon'
    click_on 'Search'

    within '.admin__search-form' do
      expect(page.find("input[type='text']").value).to eql 'bacon'
    end

    within 'tbody' do
      expect(page).to have_text(opportunity.title)
      expect(page).not_to have_text(irrelevant_opportunity.title)
    end
  end

  scenario 'search by author' do
    login_as(create(:admin))

    author = create(:uploader, name: 'Jo Smith')
    create(:opportunity, title: 'Matching', author: author)

    irrelevant_author = create(:uploader, name: 'Bill Brown')
    create(:opportunity, title: 'Irrelevant', author: irrelevant_author)

    visit admin_opportunities_path
    fill_in 's', with: 'smith'
    click_on 'Search'

    within '.admin__search-form' do
      expect(page.find("input[type='text']").value).to eq 'smith'
    end

    within 'tbody' do
      expect(page).to have_text('Matching')
      expect(page).to have_no_text('Irrelevant')
    end
  end

  scenario 'search by author email' do
    login_as(create(:admin))

    author = create(:uploader, email: 'jo.smith@example.com')
    create(:opportunity, title: 'Matching', author: author)

    irrelevant_author = create(:uploader, email: 'william.brown@example.com')
    create(:opportunity, title: 'Irrelevant', author: irrelevant_author)

    visit admin_opportunities_path
    fill_in 's', with: 'jo.smith@example.com'
    click_on 'Search'

    within '.admin__search-form' do
      expect(page.find("input[type='text']").value).to eq 'jo.smith@example.com'
    end

    within 'tbody' do
      expect(page).to have_text('Matching')
      expect(page).to have_no_text('Irrelevant')
    end
  end

  scenario 'changing search criteria maintains filters' do
    login_as(create(:uploader))

    visit admin_opportunities_path

    matching_published_opportunity = create(:opportunity, :published, title: 'matching published')
    matching_unpublished_opportunity = create(:opportunity, :unpublished, title: 'matching unpublished')
    non_matching_published_opportunity = create(:opportunity, :published, title: 'bacon')
    matching_published_expired_opportunity = create(:opportunity, :published, :expired, title: 'matching published expired')

    click_on 'Published'
    click_on 'Show expired'

    expect(page).to have_content(matching_published_opportunity.title)
    expect(page).to have_content(non_matching_published_opportunity.title)
    expect(page).to have_content(matching_published_expired_opportunity.title)
    expect(page).to have_no_content(matching_unpublished_opportunity.title)

    fill_in :s, with: 'matching'
    click_on 'Search'

    expect(page).to have_content(matching_published_opportunity.title)
    expect(page).to have_content(matching_published_expired_opportunity.title)
    expect(page).to have_no_content(non_matching_published_opportunity.title)
    expect(page).to have_no_content(matching_unpublished_opportunity.title)

    fill_in :s, with: 'bacon'
    click_on 'Search'

    expect(page).to have_content(non_matching_published_opportunity.title)
    expect(page).to have_no_content(matching_published_expired_opportunity.title)
    expect(page).to have_no_content(matching_published_opportunity.title)
    expect(page).to have_no_content(matching_unpublished_opportunity.title)
  end

  scenario 'changing sort criteria maintains search' do
    login_as(create(:uploader))

    create(:opportunity, :published, title: 'Dog Dog one', created_at: 3.months.ago)
    create(:opportunity, :published, title: 'Dog two', created_at: 4.months.ago)

    visit admin_opportunities_path

    expect(page.find('tbody tr:nth-child(1)')).to have_content('Dog one')
    expect(page.find('tbody tr:nth-child(2)')).to have_content('Dog two')

    fill_in :s, with: 'Dog'
    click_on 'Search'

    expect(page.find('tbody tr:nth-child(1)')).to have_content('Dog one')
    expect(page.find('tbody tr:nth-child(2)')).to have_content('Dog two')

    click_on 'Created date'

    expect(page.find('tbody tr:nth-child(1)')).to have_content('Dog two')
    expect(page.find('tbody tr:nth-child(2)')).to have_content('Dog one')

    click_on 'Created date'

    expect(page.find('tbody tr:nth-child(1)')).to have_content('Dog one')
    expect(page.find('tbody tr:nth-child(2)')).to have_content('Dog two')
  end
end
