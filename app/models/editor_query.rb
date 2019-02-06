class EditorQuery
  attr_reader :count, :editors

  def initialize(scope: Editor.all, sort:, page: 1, per_page: 10, hide_deactivated: false, service_provider: nil)
    @scope = scope

    @sort = sort
    @page = page
    @per_page = per_page
    @hide_deactivated = hide_deactivated
    @service_provider = service_provider
    @editors = fetch_editors
  end

  private

    def fetch_editors
      order_sql = if @sort.column == 'service_provider_name'
                    "service_providers.name #{@sort.order} NULLS LAST"
                  else
                    # We trust these values because they were whitelisted in EditorSort
                    "editors.#{@sort.column} #{@sort.order} NULLS LAST"
                  end

      query = @scope.order(order_sql)

      query = query.where(service_provider_id: @service_provider) if @service_provider.present?
      query = query.where(deactivated_at: nil) if @hide_deactivated

      query = query.page(@page).per(@per_page)

      query
    end
end
