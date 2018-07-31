class OpportunityPresenter < BasePresenter
  include ApplicationHelper

  attr_reader :title, :teaser, :description, :source, :buyer_name, :buyer_address, :countries, :tender_value, :tender_url, :opportunity_cpvs, :sectors

  delegate :expired?, to: :opportunity

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

  # Opportunity.title in required format.
  # Returns...
  # Unaltered opportunity.title when from Post.
  # 'Multi Country - [opportunity.title]' when has multiple countries.
  # '[country] - [opportunity.title]' when has single country.
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
    present_html_or_formatted_text(opportunity.description).html_safe
  end

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
    contact = ''
    if opportunity.contacts.length.positive?
      contact = if contact_email.blank?
                  contact_name
                else
                  contact_email
                end
    end

    # Final check to make sure it is not still blank.
    contact.blank? ? 'Contact unknown' : contact
  end

  def guides_available
    opportunity.countries.with_exporting_guide.any?
  end

  def country_guides
    guides = opportunity.countries.with_exporting_guide
    links = []
    if guides.length > 5
      links.push(h.link_to('Country guides', 'https://www.gov.uk/government/collections/exporting-country-guides', target: '_blank'))
    else
      guides.each do |country|
        link = link_to country.name, "https://www.gov.uk#{country.exporting_guide_path}", target: '_blank'
        links.push(link.html_safe)
      end
    end
    links
  end

  def industry_links
    links = ''
    opportunity.sectors.each_with_index do |sector, index|
      links += h.link_to sector[:name], "#{opportunities_path}?sectors[]=#{sector[:slug]}"
      links += content_tag 'span', ', ' unless index == (opportunity.sectors.length - 1)
    end
    links.html_safe
  end

  # Returns link to Government Aid Funded Business guideance, if applicable, or empty string.
  # @param text (String) visible link text
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

  def css_class_name
    if source('volume_opps')
      'opportunity-external'
    else
      'opportunity-internal'
    end
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
