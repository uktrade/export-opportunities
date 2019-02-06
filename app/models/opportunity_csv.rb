require 'csv'

class OpportunityCSV
  CSV_HEADERS = [
    'Created at',
    'First published',
    'Updated at',
    'Title',
    'Number of responses',
    'Service provider',
    'Contact email addresses',
    'Uploader email address',
    'Expiry date',
    'Countries',
    'Sectors',
    'Status',
  ].freeze

  def initialize(opportunities = Opportunity.all)
    @opportunities = opportunities.select(
      :id,
      :title,
      :enquiries_count,
      :updated_at,
      :created_at,
      :first_published_at,
      :status,
      :response_due_on,
      :service_provider_id,
      :author_id
    )

    @author_lookup = Editor.pluck(:id, :email).to_h
    @service_provider_lookup = ServiceProvider.pluck(:id, :name).to_h

    @contacts_lookup = build_contacts_hash
    @countries_lookup = build_countries_hash
    @sectors_lookup = build_sectors_hash
  end

  def each
    return enum_for(:each) unless block_given?

    yield header

    @opportunities.find_each(batch_size: 500) do |opportunity|
      yield row_for(opportunity)
    end
  end

  private

    def header
      CSV_HEADERS.join(',') + "\n"
    end

    def row_for(opportunity)
      line = [
        format_datetime(opportunity.created_at),
        format_datetime(opportunity.first_published_at),
        format_date(opportunity.updated_at),
        opportunity.title,
        opportunity.enquiries_count.to_i,
        @service_provider_lookup[opportunity.service_provider_id],
        @contacts_lookup[opportunity.id],
        @author_lookup[opportunity.author_id],
        format_date(opportunity.response_due_on),
        @countries_lookup[opportunity.id],
        @sectors_lookup[opportunity.id],
        humanize_status(opportunity.status),
      ]

      CSV.generate_line(line)
    end

    def format_datetime(datetime)
      datetime.nil? ? nil : datetime.to_s(:db)
    end

    def format_date(date)
      date.nil? ? nil : date.strftime('%Y/%m/%d')
    end

    def humanize_status(status)
      return '' unless status

      case status
      when 'publish'
        'Published'
      else
        status.titleize
      end
    end

    def build_contacts_hash
      ActiveRecord::Base
        .connection
        .select_rows("SELECT opportunity_id, STRING_AGG(email, ',') FROM contacts GROUP BY opportunity_id")
        .to_h
    end

    def build_countries_hash
      ActiveRecord::Base
        .connection
        .select_rows("SELECT countries_opportunities.opportunity_id, STRING_AGG(countries.name, ',' ORDER BY name) FROM countries_opportunities INNER JOIN countries on (countries_opportunities.country_id = countries.id) GROUP BY countries_opportunities.opportunity_id")
        .to_h
    end

    def build_sectors_hash
      ActiveRecord::Base
        .connection
        .select_rows("SELECT opportunities_sectors.opportunity_id, STRING_AGG(sectors.name, ',' ORDER BY name) FROM opportunities_sectors INNER JOIN sectors on (opportunities_sectors.sector_id = sectors.id) GROUP BY opportunities_sectors.opportunity_id")
        .to_h
    end
end
