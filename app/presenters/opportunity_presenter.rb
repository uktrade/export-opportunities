class OpportunityPresenter < BasePresenter
  attr_reader :title, :teaser, :description, :source, :buyer_name, :buyer_address, :countries, :tender_value, :tender_url, :opportunity_cpvs, :sectors

  def initialize(helpers, opportunity)
    @h = helpers
    @opportunity = opportunity
    @tender_url = opportunity.tender_url
    @tender_value = opportunity.tender_value
    @buyer_name = opportunity&.buyer_name
    @buyer_address = opportunity&.buyer_address
    @opportunity_cpvs = opportunity&.opportunity_cpvs
    @teaser = opportunity.teaser
    @sectors = opportunity.sectors
  end

  def title_with_country
    if source('post')
      opportunity.title
    else
      country = if opportunity.countries.size > 1
                  'Multi Country'
                else
                  opportunity.countries.map(&:name).join
                end
      "#{country} - #{opportunity.title}"
    end
  end

  def first_country
    opportunity.countries.size.positive? ? opportunity.countries[0][:name] : ''
  end

  def description
    h.present_html_or_formatted_text(opportunity.description).html_safe
  end

  delegate :expired?, to: :opportunity

  def expires
    opportunity.response_due_on.strftime('%d %B %Y')
  end

  def enquiries_total
    if opportunity.enquiries.size.positive?
      opportunity.enquiries.size
    else
      0
    end
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

  def contact
    if opportunity.contacts.length.positive?
      contact_email || contact_name
    else
      'Contact unknown'
    end
  end

  def guides_available
    opportunity.countries.with_exporting_guide.any? || opportunity.types.aid_funded.any?
  end

  def country_guides
    opportunity.countries.with_exporting_guide
  end

  def new_enquiry_path
    h.new_enquiry_path(slug: opportunity.slug)
  end

  def industry_links
    links = ''
    opportunity.sectors.each_with_index do |sector, index|
      links += h.link_to sector[:name], "#{opportunities_path}?sectors[]=#{sector[:slug]}"
      links += content_tag 'span', ', ' unless index == (opportunity.sectors.length - 1)
    end
    links.html_safe
  end

  def link_to_aid_funded(text)
    link = ''
    if opportunity.types.aid_funded.any?
      link = h.link_to 'https://www.gov.uk/guidance/aid-funded-business', target: '_blank' do
        text
      end
    end
    link.html_safe
  end

  def source(value = '')
    opportunity.source.eql? value
  end

  def buyer_details_empty?
    buyer_name.blank? && buyer_address.blank? && opportunity.contacts.empty?
  end

  private

  attr_reader :h, :opportunity

  def contact_name
    opportunity.contacts.first.name
  end

  def contact_email
    opportunity.contacts.first.email
  end
end
