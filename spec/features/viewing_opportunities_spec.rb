require 'rails_helper'

RSpec.feature 'Viewing opportunities', :elasticsearch, :commit do
  scenario 'Only published, non-expired opportunities are visible in the list' do
    @valid_opportunity = create(:opportunity, status: :publish)

    create(:opportunity, status: :pending)
    create(:opportunity, status: :trash)
    create(:opportunity, status: :draft)

    create(:opportunity, :expired, status: :publish)
    create(:opportunity, :expired, status: :pending)
    create(:opportunity, :expired, status: :trash)
    create(:opportunity, :expired, status: :draft)

    sleep 1
    visit opportunities_path

    within '#search-form' do
      fill_in 's', with: valid_opportunity.title
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content(valid_opportunity.title)
    expect(page).to have_selector('.results__item', count: 1)
  end

  scenario 'Potential exporter can see the response date of an opportunity' do
    opportunity = create(:opportunity, status: 'publish', response_due_on: 5.weeks.from_now)
    sleep 1
    visit opportunities_path

    within '#search-form' do
      fill_in 's', with: opportunity.title
      page.find('.filters__searchbutton').click
    end

    within '.results' do
      expect(page).to have_content(opportunity.title)
      expect(page).to have_content(opportunity.response_due_on.strftime('%d %B %Y'))
    end
  end

  scenario 'Potential exporter can see the number of enquiries for an opportunity' do
    opportunity = create(:opportunity, :published, title: 'Hello World', slug: 'hello-world')
    create_list(:enquiry, 3, opportunity: opportunity)

    sleep 1
    visit opportunities_path

    within '#search-form' do
      fill_in 's', with: 'Hello World'
      page.find('.filters__searchbutton').click
    end

    within '.results' do
      expect(page).to have_content(opportunity.title)
      expect(page).to have_content('Applications received: 3')
    end
  end

  scenario 'Opportunities should not paginate when under limit' do
    allow(Opportunity).to receive(:default_per_page).and_return(2)
    create(:opportunity, :published, title: 'Hello World', slug: 'hello-world')
    create_list(:opportunity, 1, status: 'publish')
    visit opportunities_path

    within '#search-form' do
      fill_in 's', with: 'Hello World'
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_no_selector('.pagination')
  end

  scenario 'Opportunities should paginate when over pagination limit' do
    allow(Opportunity).to receive(:default_per_page).and_return(2)
    create(:opportunity, :published, title: 'Hello World', slug: 'hello-world1')
    create(:opportunity, :published, title: 'Hello World', slug: 'hello-world2')
    create(:opportunity, :published, title: 'Hello World', slug: 'hello-world3')

    visit opportunities_path

    within '#search-form' do
      fill_in 's', with: 'Hello World'
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_selector('.pagination .current')
  end
end
