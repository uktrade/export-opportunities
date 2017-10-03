require 'rails_helper'

feature 'admin can view enquiries in opportunity show page' do
  scenario 'viewing a list of all enquiries for an opportunity' do
    admin = create(:admin)
    opportunity = create(:opportunity, :published, title: 'Hello World', slug: 'hello-world')
    enquiries_list = create_list(:enquiry, 11, opportunity: opportunity)

    login_as(admin)
    visit admin_opportunities_path

    click_on 'Hello World'

    expect(page.body).to have_content(enquiries_list[0].company_name)

    expect(page.body).to have_content(enquiries_list[5].first_name)
    expect(page.body).to have_content(enquiries_list[5].last_name)
    expect(page.body).to have_content(enquiries_list[5].company_telephone)
    expect(page.body).to have_content(enquiries_list[5].company_name)
    expect(page.body).to have_content(enquiries_list[5].company_address)
    expect(page.body).to have_content(enquiries_list[5].company_postcode)
    expect(page.body).to have_content(enquiries_list[5].company_url)
    expect(page.body).to have_content(enquiries_list[5].existing_exporter)
    expect(page.body).to have_content(enquiries_list[5].company_sector)
    expect(page.body).to have_content(enquiries_list[5].company_explanation)

    expect(page.body).to have_content(enquiries_list[10].company_name)
  end

  scenario 'only first 20 enquiries have trade profile URL' do
    admin = create(:admin)
    opportunity = create(:opportunity, :published, title: 'Hello World', slug: 'hello-world')
    create_list(:enquiry, 22, opportunity: opportunity)

    login_as(admin)
    visit admin_opportunities_path

    click_on 'Hello World'

    expect(page.body).to have_css('td.rate_ch_exceeded', count: 2)
    expect(page.body).to have_css('td.rate_trade_profile_exceeded', count: 2)
  end
end
