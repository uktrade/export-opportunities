# TODO: This should be turned into a Delagator so that it can delegate rather than duplicated some methods.
class Poc::OpportunityPresenter < BasePresenter
  attr_reader :title, :teaser, :description, :source, :buyer_name, :buyer_address, :countries, :tender_value, :tender_url, :opportunity_cpvs

  def initialize(helpers, opportunity)
    @h = helpers
    @opportunity = opportunity
    @tender_url = opportunity.tender_url
    @tender_value = opportunity.tender_value
    @buyer_name = opportunity&.buyer_name
    @buyer_name = opportunity&.buyer_address
    @opportunity_cpvs = opportunity&.opportunity_cpvs
    @teaser = opportunity.teaser
  end

  def title_with_country
    country = if opportunity.countries.size > 1
                'Multi Country'
              else
                opportunity.countries.map(&:name).join
              end
    "#{country} - #{opportunity.title}"
  end

  def description
    h.present_html_or_formatted_text(opportunity.description).html_safe
  end

  delegate :expired?, to: :opportunity

  def expires
    opportunity.response_due_on.strftime('%d %B %Y')
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

  private

  attr_reader :h, :opportunity

  def contact_name
    opportunity.contacts.first.name
  end

  def contact_email
    opportunity.contacts.first.email
  end
end
