class CreateOpportunitySlug
  def self.call(opportunity)
    new.call(opportunity)
  end

  def call(opportunity)
    return if opportunity.title.blank?

    # if the opportunity ends with -XYZ integer, then it was generated through a collision before. Lock the slug (URL)
    slug = if opportunity.slug.present? && opportunity.slug.match(/\-[0-9]{3}$/)
             opportunity.slug
           else
             opportunity.title.parameterize
           end

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
