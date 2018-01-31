require 'rails_helper'

feature 'Admins sorting the list of opportunities', :elasticsearch, :commit do
  scenario 'Sort by title' do
    publisher = create(:publisher)
    first_opportunity = create(:opportunity, title: 'Aardvark', created_at: 2.months.ago, response_due_on: 12.months.from_now)
    second_opportunity = create(:opportunity, title: 'Bear', created_at: 3.months.ago, response_due_on: 24.months.from_now)
    third_opportunity = create(:opportunity, title: 'Capybara', created_at: 1.month.ago, response_due_on: 18.months.from_now)

    login_as(publisher)
    visit admin_opportunities_path

    # Sorted in reverse date order by default
    expect(page.find('tbody tr:nth-child(1)')).to have_content(third_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(first_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(second_opportunity.title)

    click_on 'Title'

    # Sort by title
    expect(page.find('tbody tr:nth-child(1)')).to have_content(first_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(second_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(third_opportunity.title)
  end

  scenario 'Sort by created date' do
    publisher = create(:publisher)
    first_opportunity = create(:opportunity, title: 'Aardvark', created_at: 2.months.ago, response_due_on: 12.months.from_now)
    second_opportunity = create(:opportunity, title: 'Bear', created_at: 3.months.ago, response_due_on: 24.months.from_now)
    third_opportunity = create(:opportunity, title: 'Capybara', created_at: 1.month.ago, response_due_on: 18.months.from_now)

    login_as(publisher)
    visit admin_opportunities_path

    # Sorted in reverse date order by default
    expect(page.find('tbody tr:nth-child(1)')).to have_content(third_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(first_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(second_opportunity.title)

    click_on 'Created date'

    # Because created date is the default sort order the order will be reversed
    expect(page.find('tbody tr:nth-child(1)')).to have_content(second_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(first_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(third_opportunity.title)
  end

  scenario 'Sort by expiry date' do
    publisher = create(:publisher)
    first_opportunity = create(:opportunity, title: 'Aardvark', created_at: 2.months.ago, response_due_on: 12.months.from_now)
    second_opportunity = create(:opportunity, title: 'Bear', created_at: 3.months.ago, response_due_on: 24.months.from_now)
    third_opportunity = create(:opportunity, title: 'Capybara', created_at: 1.month.ago, response_due_on: 18.months.from_now)

    login_as(publisher)
    visit admin_opportunities_path

    # Sorted in reverse date order by default
    expect(page.find('tbody tr:nth-child(1)')).to have_content(third_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(first_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(second_opportunity.title)

    click_on 'Expiry date'

    expect(page.find('tbody tr:nth-child(1)')).to have_content(first_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(third_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(second_opportunity.title)
  end

  scenario 'Sort by enquiries received' do
    publisher = create(:publisher)
    first_opportunity = create(:opportunity, title: 'Aardvark', created_at: 2.months.ago, response_due_on: 12.months.from_now)
    second_opportunity = create(:opportunity, title: 'Bear', created_at: 3.months.ago, response_due_on: 24.months.from_now)
    third_opportunity = create(:opportunity, title: 'Capybara', created_at: 1.month.ago, response_due_on: 18.months.from_now)

    create_list(:enquiry, 4, opportunity: first_opportunity)
    create_list(:enquiry, 3, opportunity: second_opportunity)
    create_list(:enquiry, 2, opportunity: third_opportunity)

    login_as(publisher)
    visit admin_opportunities_path

    # Sorted in reverse date order by default
    expect(page.find('tbody tr:nth-child(1)')).to have_content(third_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(first_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(second_opportunity.title)

    click_on 'Enquiries received'

    expect(page.find('tbody tr:nth-child(1)')).to have_content(first_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(second_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(third_opportunity.title)
  end

  scenario 'Sort by Service provider' do
    publisher = create(:publisher)
    first_service_provider = create(:service_provider, name: 'Italy Rome')
    second_service_provider = create(:service_provider, name: 'Italy Naples')
    third_service_provider = create(:service_provider, name: 'France Paris')

    first_opportunity = create(:opportunity, title: 'Aardvark', created_at: 2.months.ago, response_due_on: 12.months.from_now, service_provider: first_service_provider)
    second_opportunity = create(:opportunity, title: 'Bear', created_at: 3.months.ago, response_due_on: 24.months.from_now, service_provider: second_service_provider)
    third_opportunity = create(:opportunity, title: 'Capybara', created_at: 1.month.ago, response_due_on: 18.months.from_now, service_provider: third_service_provider)

    login_as(publisher)
    visit admin_opportunities_path

    # Sorted in reverse date order by default
    expect(page.find('tbody tr:nth-child(1)')).to have_content(third_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(first_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(second_opportunity.title)

    click_on 'Service provider'

    expect(page.find('tbody tr:nth-child(1)')).to have_content(third_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(second_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(first_opportunity.title)
  end

  scenario 'Sort by Service provider' do
    uploader = create(:uploader)
    first_service_provider = create(:service_provider, name: 'Italy Rome')
    second_service_provider = create(:service_provider, name: 'Italy Naples')
    third_service_provider = create(:service_provider, name: 'France Paris')

    first_opportunity = create(:opportunity, status: :publish, title: 'Aardvark', created_at: 2.months.ago, response_due_on: 12.months.from_now, service_provider: first_service_provider)
    second_opportunity = create(:opportunity, status: :publish, title: 'Bear', created_at: 3.months.ago, response_due_on: 24.months.from_now, service_provider: second_service_provider)
    third_opportunity = create(:opportunity, status: :publish, title: 'Capybara', created_at: 1.month.ago, response_due_on: 18.months.from_now, service_provider: third_service_provider)

    login_as(uploader)
    visit admin_opportunities_path

    # Sorted in reverse date order by default
    expect(page.find('tbody tr:nth-child(1)')).to have_content(third_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(first_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(second_opportunity.title)

    click_on 'Service provider'

    expect(page.find('tbody tr:nth-child(1)')).to have_content(third_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(second_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(first_opportunity.title)
  end

  scenario 'Editors can toggle the sort order by clicking on the header repeatedly' do
    publisher = create(:publisher)

    old_opportunity = create(:opportunity, created_at: 1.month.ago)
    new_opportunity = create(:opportunity, created_at: DateTime.current)

    login_as(publisher)
    visit admin_opportunities_path

    click_on 'Created date' # Sort by date ascending

    expect(old_opportunity.title).to appear_before(new_opportunity.title)

    click_on 'Created date' # Sort by date descending

    expect(new_opportunity.title).to appear_before(old_opportunity.title)
  end

  scenario 'sorting when paginated' do
    create(:opportunity, title: 'last opp')
    create_list(:opportunity, Admin::OpportunitiesController::OPPORTUNITIES_PER_PAGE)

    login_as(create(:publisher))
    visit '/admin/opportunities?paged=2'
    within('.pagination') { click_link '2' }

    column_sort_link = page.find_link('Title')[:href]
    page_number = CGI.parse(URI.parse(column_sort_link).query)['paged'].first
    expect(page_number).to eq '1'
  end

  scenario 'Visit pending state, should sort by RAGG' do
    publisher = create(:publisher)
    first_opportunity = create(:opportunity, title: 'Aardvark', ragg: :red, created_at: 2.months.ago, response_due_on: 12.months.from_now)
    second_opportunity = create(:opportunity, title: 'Bear', ragg: :undefined, created_at: 3.months.ago, response_due_on: 24.months.from_now)
    third_opportunity = create(:opportunity, title: 'Capybara', ragg: :blue, created_at: 1.month.ago, response_due_on: 18.months.from_now)

    login_as(publisher)
    visit admin_opportunities_path
    click_on('Pending')

    # Sorted in ragg order by default
    expect(page.find('tbody tr:nth-child(1)')).to have_content(second_opportunity.title)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(third_opportunity.title)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(first_opportunity.title)
  end
end
