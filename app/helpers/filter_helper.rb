module FilterHelper
  def service_providers_select(*id)
    select_tag 'service_provider', options_from_collection_for_select(ServiceProvider.order(name: :asc), 'id', 'name', id), prompt: 'All'
  end
end
