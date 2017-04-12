class OpportunityHistory
  include Enumerable

  def initialize(opportunity:)
    revisions = opportunity.versions.where(event: :update)
    comments = opportunity.comments.preload(:author, :opportunity)

    @history = (revisions + comments).sort_by(&:created_at)
  end

  def each(&block)
    @history.each(&block)
  end
end
