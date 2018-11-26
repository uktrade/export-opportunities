class OpportunityPresenter < PagePresenter
  include ApplicationHelper
  attr_reader :title, :teaser, :description, :source, :buyer_name, :buyer_address, :countries, :tender_value, :tender_url, :target_url, :opportunity_cpvs, :sectors, :sign_off

  delegate :expired?, to: :opportunity

  def initialize(view_context, opportunity, content = {})
    @view_context = view_context
    @opportunity = opportunity
    @content = content
    @tender_url = opportunity.tender_url
    @target_url = opportunity.target_url
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
    # Remove special country values (e.g. 'DIT HQ')
    countries = opportunity.countries.where.not(id: [198, 199, 142, 200])
    if source('post') && (opportunity.created_at < Date.parse(Figaro.env.POST_FORM_DEPLOYMENT_DATE) || (!countries.empty? && countries.map(&:region_id).include?(18)))
      opportunity.title
    else
      country = if countries.size > 1
                  'Multi Country'
                else
                  countries.map(&:name).join
                end

      if country.present?
        "#{country} - #{opportunity.title}"
      else
        opportunity.title
      end
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
    contact_email if opportunity.contacts.length.positive?
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

  def supplier_preferences
    opportunity.supplier_preferences.map(&:name).join(', ')
  end

  def supplier_preference?
    if opportunity.respond_to? :supplier_preference_ids
      opportunity.supplier_preference_ids.present?
    end
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

  def translated?
    opportunity.original_language.casecmp('en') != 0
  end

  def published_date
    if opportunity.first_published_at.present?
      opportunity.first_published_at.strftime('%d %B %Y')
    else
      ''
    end
  end

  def formatted_date(date_field_name)
    if opportunity[date_field_name].present?
      opportunity[date_field_name].strftime('%d %B %Y')
    else
      ''
    end
  end

  # Return appropriate sign off line(s) for display
  # with Opportunity details. Relies on working out
  # content based on passed service provider, unless
  # is third-party, which has separate sign off.
  def sign_off_content(service_provider = opportunity.service_provider)
    partner = service_provider[:partner]
    name = service_provider[:name]
    country = service_provider.country
    country_name = country.nil? ? '' : country.name # compensate for poor data
    lines = []
    if @target_url.present?
      lines.push @content['sign_off_target_url']

    elsif source('volume_opps')
      lines.push @content['sign_off_volume_opps']

    elsif partner.present?
      lines.push content_with_inclusion('sign_off_partner_1', [partner, country_name])
      lines.push content_with_inclusion('sign_off_partner_2', [partner, country_name])

    elsif ['DIT Education', 'DIT HQ', 'DSO HQ', 'DSO RD West 2 / NATO',
           'Occupied Palestinian Territories Jerusalem', 'UKEF', 'UKREP',
           'United Kingdom LONDON', 'USA AFB', 'USA OBN OCO', 'USA OBN Sannam S4'].include? name
      lines.push @content['sign_off_dit']

    elsif name.match(/Czech Republic \w+|Dominican Republic \w+|Ivory Coast \w+|Netherlands \w+|Philippines \w+|United Arab Emirates \w+|United States \w+/)
      lines.push content_with_inclusion('sign_off_default', ['the ', country_name])

    # Exceptions where we need to use Region name
    elsif name.match(/.*Africa.* \w+|Cameroon \w+|Egypt \w+|Kenya OBNI|Nabia \w+|Rwanda \w+|Senegal \w+|Seychelles \w+|Tanzania \w+|Tunisia \w+|Zambia \w+/)
      lines.push content_with_inclusion('sign_off_default', ['', country.region.name])

    else
      # Default sign off
      lines.push content_with_inclusion('sign_off_default', ['', country_name])

    end
    lines
  end

  private

  attr_reader :view_context, :opportunity

  def contact_email
    opportunity.contacts.first.email
  end
end
