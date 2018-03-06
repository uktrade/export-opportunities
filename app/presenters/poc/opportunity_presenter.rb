class Poc::OpportunityPresenter < BasePresenter
  attr_reader :title, :teaser, :description, :source, :buyer_name, :buyer_address, :countries, :types

  def initialize(helpers, opportunity)
    @h = helpers
    @opportunity = opportunity
    @teaser = opportunity.teaser
    @source = opportunity.source
    @buyer_name = opportunity&.buyer_name
    @buyer_name = opportunity&.buyer_address
  end

  def title_with_country
    if opportunity.countries.size > 1
      country = 'Multi Country'
    else
      country = opportunity.countries.map(&:name).join
    end
    "#{country} - #{opportunity.title}"
  end

  def description
    h.present_html_or_formatted_text(opportunity.description).html_safe
  end

  def expires
    opportunity.response_due_on.strftime('%d %B %Y')
  end

  def has_expired
    opportunity.expired?
  end

  def enquiries_total
    opportunity.enquiries.size
  end

  def type
    opportunity.types.pluck(:name).to_sentence
  end

  def sectors_as_string
    opportunity.sectors.pluck(:name).to_sentence
  end

  def value
    if opportunity.values.any?
      opportunity.values.first.name
    else
      'Value unknown'
    end
  end

  def contact_name
    opportunity.contacts.first.name
  end

  def contact_email
    opportunity.contacts.first.email
  end

  def guides_available
    opportunity.countries.with_exporting_guide.any? || opportunity.types.aid_funded.any?
  end

  def country_guide_links
    links = ''
    opportunity.countries.with_exporting_guide.each do |country|
      links += h.link_to "https://www.gov.uk#{country.exporting_guide_path}", target: '_blank' do
        country.name
      end
    end
    links.html_safe
  end

  def new_enquiry_path
    h.new_enquiry_path(slug: opportunity.slug)
  end

  def link_to_aid_funded(text)
    if opportunity.types.aid_funded.any?
      h.link_to 'https://www.gov.uk/guidance/aid-funded-business', target: '_blank' do
        text
      end
    end
    text.html_safe
  end

  private

  attr_reader :h, :opportunity
end
