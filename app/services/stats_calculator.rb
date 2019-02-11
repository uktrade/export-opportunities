class StatsCalculator
  Stats = ImmutableStruct.new(:opportunities_submitted, :opportunities_published, :enquiries, :enquiry_response, :average_age_when_published)

  def call(criteria)
    date_range = (criteria.date_from..criteria.date_to)
    source = criteria.source
    case criteria.granularity
    when 'ServiceProvider'
      if criteria.all_service_providers?
        opportunities_submitted, opportunities_published, enquiries, enquiry_response = global_results(date_range)
      else
        opportunities_submitted = Opportunity.where(service_provider_id: criteria.service_provider_id, created_at: date_range).count
        opportunities_published = Opportunity.where(service_provider_id: criteria.service_provider_id, first_published_at: date_range)
        enquiries = Enquiry.joins(:opportunity).where(opportunities: { service_provider_id: criteria.service_provider_id }, created_at: date_range).count
        enquiry_response = Enquiry.joins(:enquiry_response).joins(:opportunity).where(opportunities: { service_provider_id: criteria.service_provider_id }, enquiry_responses: { created_at: date_range }).where.not(enquiry_responses: { completed_at: nil }).count
      end
    when 'Country'
      service_providers = []
      criteria.country_id.each do |country|
        service_providers << service_providers(country)
      end
      service_providers = service_providers.uniq.flatten

      opportunities_submitted, opportunities_published, enquiries, enquiry_response = results_with_filters(service_providers, date_range)
    when 'Region'
      service_providers = []
      countries_arr = []

      criteria.region_id.each do |region|
        countries_arr << countries(region)
      end
      countries = countries_arr.uniq.flatten

      countries.each do |country|
        service_providers << service_providers(country.id)
      end
      service_providers = service_providers.uniq.flatten

      opportunities_submitted, opportunities_published, enquiries, enquiry_response = results_with_filters(service_providers, date_range)
    when 'Universe'
      opportunities_submitted, opportunities_published, enquiries, enquiry_response = if source
                                                                                        global_results_by_source(date_range, source)
                                                                                      else
                                                                                        global_results(date_range)
                                                                                      end
    end

    Stats.new(opportunities_submitted: opportunities_submitted,
              opportunities_published: opportunities_published.count,
              enquiries: enquiries,
              enquiry_response: enquiry_response,
              average_age_when_published: average_age_when_published(opportunities_published))
  end

  private

    def global_results(date_range)
      opportunities_submitted = Opportunity.where(created_at: date_range).count
      opportunities_published = Opportunity.where(first_published_at: date_range)
      enquiries = Enquiry.joins(:opportunity).where(created_at: date_range).count
      enquiry_response = EnquiryResponse.joins(:enquiry).where(created_at: date_range).count
      [opportunities_submitted, opportunities_published, enquiries, enquiry_response]
    end

    def global_results_by_source(date_range, opportunity_source)
      opportunities_submitted = Opportunity.where(created_at: date_range).where(source: opportunity_source).count
      opportunities_published = Opportunity.where(first_published_at: date_range).where(source: opportunity_source)
      enquiries = if opportunity_source.eql?(:post)
                    Enquiry.joins(:opportunity).where(created_at: date_range).count
                  else
                    0
                  end
      enquiry_response = if opportunity_source.eql?(:post)
                           EnquiryResponse.joins(:enquiry).where(created_at: date_range).count
                         else
                           0
                         end
      [opportunities_submitted, opportunities_published, enquiries, enquiry_response]
    end

    def results_with_filters(service_providers, date_range)
      opportunities_submitted = Opportunity.where(service_provider_id: service_providers.map(&:id), created_at: date_range).count
      opportunities_published = Opportunity.where(service_provider_id: service_providers.map(&:id), first_published_at: date_range)
      enquiries = Enquiry.joins(:opportunity).where(opportunities: { service_provider_id: service_providers.map(&:id) }, created_at: date_range).count

      enquiry_response = Enquiry.joins(:enquiry_response).joins(:opportunity).where(opportunities: { service_provider_id: service_providers.map(&:id) }, enquiry_responses: { created_at: date_range }).where.not(enquiry_responses: { completed_at: nil }).count
      [opportunities_submitted, opportunities_published, enquiries, enquiry_response]
    end

    def average_age_when_published(opportunities)
      return nil if opportunities.empty?

      opportunity_ages = opportunities.map { |opp| opp.first_published_at - opp.created_at }
      (opportunity_ages.sum / opportunities.count) / 60 / 60
    end

    def countries(region_id)
      Region.find(region_id).countries
    end

    def service_providers(country_id)
      Country.find(country_id).service_providers
    end
end
