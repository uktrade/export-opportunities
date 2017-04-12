require 'rails_helper'

RSpec.feature 'Viewing opportunities' do
  scenario 'Only published, non-expired opportunities are visible in the list' do
    valid_opportunity = create(:opportunity, status: :publish)
    create(:opportunity, status: :pending)
    create(:opportunity, status: :trash)

    create(:opportunity, :expired, status: :publish)
    create(:opportunity, :expired, status: :pending)
    create(:opportunity, :expired, status: :trash)

    visit opportunities_path

    expect(page).to have_content(valid_opportunity.title)
    expect(page).to have_selector('.opportunities__item', count: 1)
  end

  scenario 'Potential exporter can view all opportunities' do
    opportunities = create_list(:opportunity, 3, status: 'publish')

    visit opportunities_path

    within '.opportunities' do
      opportunities.each do |opportunity|
        expect(page).to have_content(opportunity.title)
      end
    end
  end

  scenario 'Potential exporter can see the response date of an opportunity' do
    opportunity = create(:opportunity, status: 'publish', response_due_on: 5.weeks.from_now)

    visit opportunities_path

    within '.opportunities' do
      expect(page).to have_content(opportunity.title)
      expect(page).to have_content(opportunity.response_due_on.strftime('%d %B %Y'))
    end
  end

  scenario 'Potential exporter can see the number of enquiries for an opportunity' do
    opportunity = create(:opportunity, :published, title: 'Hello World', slug: 'hello-world')
    create_list(:enquiry, 3, opportunity: opportunity)

    visit opportunities_path
    within '.opportunities' do
      expect(page).to have_content(opportunity.title)
      expect(page).to have_content('Applications received: 3')
    end
  end

  scenario 'Opportunities should not paginate when under limit' do
    allow(Opportunity).to receive(:default_per_page).and_return(2)
    create_list(:opportunity, 1, status: 'publish')
    visit opportunities_path

    expect(page).to have_no_selector('.pagination')
  end

  scenario 'Opportunities should paginate when over pagination limit' do
    allow(Opportunity).to receive(:default_per_page).and_return(2)
    create_list(:opportunity, 3, status: 'publish')
    visit opportunities_path

    expect(page).to have_selector('.pagination .current')
  end

  scenario 'When opps are loaded via JS, pagination links do not carry the .js extension', js: true do
    allow(Opportunity).to receive(:default_per_page).and_return(1)
    create_list(:opportunity, 2, status: :publish)
    visit opportunities_path

    within '.pagination' do
      click_on '2'
    end

    within '.pagination' do
      expect(page.find("a[rel='prev']")[:href]).not_to match(/\.js/)
    end
  end
end
