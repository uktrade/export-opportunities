class StatsCalculator
  Stats = ImmutableStruct.new(:opportunities_submitted, :opportunities_published, :enquiries, :average_age_when_published)

  def call(criteria)
    date_range = (criteria.date_from..criteria.date_to)
    if criteria.all_service_providers?
      opportunities_submitted = Opportunity.where(created_at: date_range).count
      opportunities_published = Opportunity.where(first_published_at: date_range)
      enquiries = Enquiry.joins(:opportunity).where(created_at: date_range).count
    else
      opportunities_submitted = Opportunity.where(service_provider_id: criteria.service_provider_id, created_at: date_range).count
      opportunities_published = Opportunity.where(service_provider_id: criteria.service_provider_id, first_published_at: date_range)
      enquiries = Enquiry.joins(:opportunity).where(opportunities: { service_provider_id: criteria.service_provider_id }, created_at: date_range).count
    end

    Stats.new(opportunities_submitted: opportunities_submitted,
              opportunities_published: opportunities_published.count,
              enquiries: enquiries,
              average_age_when_published: average_age_when_published(opportunities_published))
  end

  private

  def average_age_when_published(opportunities)
    return nil if opportunities.empty?
    opportunity_ages = opportunities.map { |opp| opp.first_published_at - opp.created_at }
    (opportunity_ages.sum / opportunities.count) / 60 / 60
  end
end
