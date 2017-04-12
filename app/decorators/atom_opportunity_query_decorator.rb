class AtomOpportunityQueryDecorator < SimpleDelegator
  def initialize(query, view_context)
    super(query)

    @view_context = view_context
    @params = view_context.params
  end

  def opportunities
    @opportunities ||= begin
                         scope = super

                         scope = scope.preload(:sectors).preload(:author)
                         scope = scope.reorder(updated_at: :desc, created_at: :desc)

                         scope
                       end
  end

  def feed_root_url
    @view_context.url_for(@params.merge(only_path: false, format: nil))
  end

  def feed_updated_at
    opportunities.first.updated_at unless opportunities.empty?
  end

  def next_page
    @view_context.url_for(@params.merge(only_path: false, paged: opportunities.current_page + 1))
  end

  def prev_page
    @view_context.url_for(@params.merge(only_path: false, paged: [opportunities.current_page, opportunities.total_pages].min - 1))
  end

  def next_page?
    opportunities.current_page < opportunities.total_pages
  end

  def prev_page?
    opportunities.current_page > 1
  end
end
