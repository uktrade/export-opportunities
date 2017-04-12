class CreateOpportunitySlug
  def self.call(opportunity)
    new.call(opportunity)
  end

  def call(opportunity)
    return unless opportunity.title.present?

    slug = opportunity.title.parameterize

    3.times do
      return slug unless duplicate?(slug, opportunity.id)
      slug = "#{opportunity.title.parameterize}-#{rand}"
    end

    opportunity.title.parameterize
  end

  private def duplicate?(slug, id)
    duplicates = Opportunity.where(slug: slug)
    duplicates = duplicates.where.not(id: id) if id.present?
    duplicates.count.positive?
  end

  private def rand
    @rand ||= Random.new
    @rand.rand(999)
  end
end
