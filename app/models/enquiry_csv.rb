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
    'Date enquiry submitted',
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
    'Enquiry Response status',
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

    # Get unique IDs to minimize data loading
    @user_ids = @enquiries.pluck(:user_id).uniq
    @opportunity_ids = @enquiries.pluck(:opportunity_id).uniq
  end

  def each
    return enum_for(:each) unless block_given?

    yield header

    # Load lookup data in batches to reduce memory usage
    users_lookup = load_users_lookup
    opportunities_lookup = load_opportunities_lookup
    service_provider_lookup = load_service_providers_lookup
    countries_lookup = load_countries_lookup

    @enquiries.find_each(batch_size: 100) do |enquiry|
      yield row_for(enquiry, users_lookup, opportunities_lookup, service_provider_lookup, countries_lookup)
    end
  end

  private

    def header
      CSV_HEADERS.join(',') + "\n"
    end

    def row_for(enquiry, users_lookup, opportunities_lookup, service_provider_lookup, countries_lookup)
      line = [
        enquiry.company_name,
        enquiry.first_name,
        enquiry.last_name,
        enquiry.company_address,
        enquiry.company_postcode,
        enquiry.company_telephone,
        format_datetime(enquiry.created_at),
        enquiry.company_sector,
        opportunities_lookup[enquiry.opportunity_id],
        countries_lookup[enquiry.opportunity_id],
        users_lookup[enquiry.user_id],
        service_provider_lookup[enquiry.opportunity_id],
        enquiry.data_protection ? 'Yes' : 'No',
        enquiry.company_house_number,
        enquiry.company_url,
        enquiry.existing_exporter,
        enquiry.company_explanation,
        enquiry.response_status,
        enquiry.enquiry_response ? format_response_type(enquiry.enquiry_response.response_type) : 'none',
        enquiry.enquiry_response ? ActionView::Base.full_sanitizer.sanitize(enquiry.enquiry_response.email_body) : 'none',
        enquiry.enquiry_response ? format_datetime(enquiry.enquiry_response['completed_at']) : 'none',
      ]

      CSV.generate_line(line)
    end

    def load_users_lookup
      # Only load the users we need
      User.where(id: @user_ids).pluck(:id, :email).to_h
    end

    def load_opportunities_lookup
      # Only load the opportunities we need
      Opportunity.where(id: @opportunity_ids).pluck(:id, :title).to_h
    end

    def load_countries_lookup
      return {} if @opportunity_ids.empty?

      countries_data = CountriesOpportunity
        .joins(:country)
        .where(opportunity_id: @opportunity_ids)
        .group(:opportunity_id)
        .select("opportunity_id, STRING_AGG(countries.name, ' ' ORDER BY name)")
        .map { |record| [record.opportunity_id, record.string_agg] }

      Hash[countries_data]
    end

    def load_service_providers_lookup
      return {} if @opportunity_ids.empty?

      Opportunity
        .joins(:service_provider)
        .where(id: @opportunity_ids)
        .pluck(:id, 'service_providers.name')
        .to_h
    end

    def format_datetime(datetime)
      datetime.nil? ? nil : datetime.strftime('%Y/%m/%d %H:%M')
    end

    def format_response_type(response_type)
      to_h(response_type)
    end
end
