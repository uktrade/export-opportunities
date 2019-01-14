class AtomOpportunityQueryDecorator < SimpleDelegator
  def initialize(query, view_context)
    @query = query.preload(:sectors).preload(:author).reorder(updated_at: :desc)
    super(@query)

    @view_context = view_context
    @params = view_context.params
  end

  def feed_root_url
    @view_context.url_for(@params.merge(only_path: false, format: nil))
  end

  def feed_updated_at
    @query.first.updated_at unless @query.empty?
  end

  def next_page
    @view_context.url_for(@params.merge(only_path: false, paged: @query.current_page + 1))
  end

  def prev_page
    @view_context.url_for(@params.merge(only_path: false, paged: [@query.current_page, @query.total_pages].min - 1))
  end

  def next_page?
    @query.current_page < @query.total_pages
  end

  def prev_page?
    @query.current_page > 1
  end
end
