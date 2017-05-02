require 'rails_helper'

RSpec.feature 'Viewing an individual opportunity', :elasticsearch, :commit do
  scenario 'pending and trashed opportunities are not accessible' do
    opportunities = [
      create(:opportunity, status: :pending),
      create(:opportunity, status: :trash),
    ]

    opportunities.each do |opportunity|
      visit "opportunities/#{opportunity.slug}"
      expect(page).to have_content t('errors.not_found')
    end
  end

  scenario 'published but expired opportunities are accessible' do
    create(:opportunity, :expired, status: :publish, title: 'Hairdressers wanted', slug: 'hairdressers-wanted')
    visit 'opportunities/hairdressers-wanted'

    expect(page).to have_content 'Hairdressers wanted'
    expect(page).to have_content t('opportunity.expired')
  end

  scenario 'Potential exporter can view details of an opportunity' do
    sectors = create_list(:sector, 3)
    types = create_list(:type, 5)
    countries = [create(:country, exporting_guide_path: '/somelink')]

    opportunity = create(:opportunity, status: 'publish', sectors: sectors, types: types, countries: countries)

    create_list(:enquiry, 3, opportunity: opportunity)

    sleep 1
    visit opportunities_path
    click_on opportunity.title
    expect(page).to have_content opportunity.title

    sectors.each do |s|
      expect(page).to have_content s.name
    end

    countries.each do |c|
      expect(page).to have_content c.name
    end

    types.each do |t|
      expect(page).to have_content t.name
    end

    expect(page).to have_content opportunity.teaser
    expect(page).to have_content opportunity.description
    expect(page).to have_content opportunity.response_due_on.strftime('%d %B %Y')
    expect(page).to have_link 'Your guide to exporting'
    expect(page).to have_link 'Apply for this opportunity'
    expect(page).to have_content('Applications received: 3')
  end

  scenario 'country with a link to exporting guide' do
    country = create(:country, exporting_guide_path: '/government/publications/exporting-to-egypt')
    opportunity = create(:opportunity, status: :publish, response_due_on: 3.months.from_now, countries: [country])
    visit opportunity_path(opportunity.id)
    expect(page).to have_link(country.name, href: 'https://www.gov.uk/government/publications/exporting-to-egypt')
    expect(page).to have_content('Your guide to exporting')
  end

  scenario 'not all countries having links to exporting guide' do
    with_guide = create(:country, exporting_guide_path: '/government/publications/exporting-to-egypt')
    without_guide = create(:country)
    opportunity = create(:opportunity, status: :publish, response_due_on: 3.months.from_now, countries: [with_guide, without_guide])

    visit opportunity_path(opportunity.id)
    expect(page).to have_link(with_guide.name, href: 'https://www.gov.uk/government/publications/exporting-to-egypt')
    expect(page).not_to have_link(without_guide.name)
  end

  scenario 'country without a link to exporting guide' do
    country = create(:country)
    create(:opportunity, response_due_on: 3.months.from_now, countries: [country])
    opportunity = create(:opportunity, status: :publish, response_due_on: Date.new(2016, 0o1, 12), countries: [country])
    visit opportunity_path(opportunity.id)
    expect(page).not_to have_link(country.name)
    expect(page).not_to have_content('Your guide to exporting')
  end

  scenario 'aid funded opportunities have links to aid guidance' do
    aid_type = create(:type, slug: 'aid-funded-business', name: 'Aid Funded Business')
    opportunity = create(:opportunity, status: :publish, response_due_on: 3.months.from_now, types: [aid_type])

    visit opportunity_path(opportunity.id)

    expect(page).to have_link('Your guide for aid funded business')
  end

  scenario 'Opportunity view should filter HTML' do
    acceptable_html_examples = [
      { html: '<b>Foo</b>', selector: 'b' },
      { html: '<i>Bar</i>', selector: 'i' },
      { html: '<ul><li>Baz</li><li>Bong</li></ul>', selector: 'ul li' },
      { html: '<ol><li>Doo</li><li>Dah</li></ol>', selector: 'ol li' },
      { html: '<p>1</p>', selector: 'p' },
    ]
    acceptable_html_examples.each do |example|
      op = create(:opportunity, status: 'publish', description: example[:html])
      visit opportunity_path(op.id)
      expect(page).to have_css('.opportunity__content ' + example[:selector])
    end

    unacceptable_html_examples = [
      { html: '<a href="http://thisisnotreallypaypal.com">Give us money</a>', selector: 'a' },
      { html: '<script>Foo</script>', selector: 'script' },
      { html: '<iframe src="evil.html" />', selector: 'iframe' },
      { html: '<blink>182</blink>', selector: 'blink' },
      { html: '<marquee>Funtimes</marquee>', selector: 'marquee' },
    ]
    unacceptable_html_examples.each do |example|
      op = create(:opportunity, status: 'publish', description: example[:html])
      visit opportunity_path(op.id)
      expect(page).not_to have_css('.opportunity__content ' + example[:selector])
    end
  end

  scenario 'Opportuntiy view should render plain text nicely' do
    example = <<-EOD
Our clients in Hackistan want to import the finest Wimbledon wombles.

Wombles from Richmond or Hammersmith or Barnes or Westminster will not do.

They must be from Wimbledon.
EOD

    op = create(:opportunity, status: 'publish', description: example)
    visit opportunity_path(op.id)
    expect(page).to have_css('.opportunity__content p:nth-last-child(3)')
  end

  scenario "Opportunity view shouldn't use simple_format when HTML present" do
    example = <<-EOD
Lorem ipsum. <b>Dolor sit amet!</b>

We shall rapidiously right-shore fully tested sources.
EOD

    op = create(:opportunity, description: example)
    visit opportunity_path(op.id)
    expect(page).not_to have_css('.opportunity_description')
  end
end
