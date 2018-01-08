require 'csv'

class EnquiryCSV
  include EnquiryResponseHelper
  CSV_HEADERS = [
    'Company Name',
    'First Name',
    'Last Name',
    'Company Address',
    'Company Postcode',
    'Company Telephone number',
    'Date response submitted',
    "Company's Sector",
    'Opportunity Title',
    'Countries',
    'Email Address',
    'Service provider',
    'Terms accepted',
    'Companies House Number',
    'Company URL',
    'Have they sold products or services to overseas customers?',
    'How the company can meet the requirements in this opportunity',
    'Enquiry response reply',
    'Enquiry response text',
    'Enquiry response timestamp',
  ].freeze

  def initialize(enquiries = Enquiry.all)
    @enquiries = enquiries.select(
      :company_address,
      :company_explanation,
      :company_house_number,
      :company_name,
      :company_postcode,
      :company_sector,
      :company_telephone,
      :company_url,
      :created_at,
      :data_protection,
      :user_id,
      :existing_exporter,
      :first_name,
      :id,
      :last_name,
      :opportunity_id
    ).includes(:enquiry_response)

    @users_lookup = User.pluck(:id, :email).to_h
    @opportunities_lookup = Opportunity.pluck(:id, :title).to_h
    @service_provider_lookup = build_service_providers_hash
    @countries_lookup = build_countries_hash
  end

  def each
    return enum_for(:each) unless block_given?

    yield header

    @enquiries.find_each(batch_size: 500) do |enquiry|
      yield row_for(enquiry)
    end
  end

  private def header
    CSV_HEADERS.join(',') + "\n"
  end

  private def row_for(enquiry)
    line = [
      enquiry.company_name,
      enquiry.first_name,
      enquiry.last_name,
      enquiry.company_address,
      enquiry.company_postcode,
      enquiry.company_telephone,
      format_datetime(enquiry.created_at),
      enquiry.company_sector,
      @opportunities_lookup[enquiry.opportunity_id],
      @countries_lookup[enquiry.opportunity_id],
      @users_lookup[enquiry.user_id],
      @service_provider_lookup[enquiry.opportunity_id],
      enquiry.data_protection ? 'Yes' : 'No',
      'N/A',
      enquiry.company_house_number,
      enquiry.company_url,
      enquiry.existing_exporter,
      enquiry.company_explanation,
      enquiry.enquiry_response ? format_response_type(enquiry.enquiry_response.response_type) : 'none',
      enquiry.enquiry_response ? ActionView::Base.full_sanitizer.sanitize(enquiry.enquiry_response.email_body) : 'none',
      enquiry.enquiry_response ? format_datetime(enquiry.enquiry_response['completed_at']) : 'none',
    ]

    CSV.generate_line(line)
  end

  private def build_countries_hash
    ActiveRecord::Base
      .connection
      .select_rows("SELECT countries_opportunities.opportunity_id, STRING_AGG(countries.name, ' ' ORDER BY name) FROM countries_opportunities INNER JOIN countries on (countries_opportunities.country_id = countries.id) GROUP BY countries_opportunities.opportunity_id")
      .to_h
  end

  private def build_service_providers_hash
    ActiveRecord::Base
      .connection
      .select_rows('SELECT opportunities.id, service_providers.name FROM opportunities INNER JOIN service_providers ON (opportunities.service_provider_id = service_providers.id)')
      .to_h
  end

  private def format_datetime(datetime)
    datetime.nil? ? nil : datetime.strftime('%Y/%m/%d %H:%M')
  end

  private def format_response_type(response_type)
    to_h(response_type)
  end
end
