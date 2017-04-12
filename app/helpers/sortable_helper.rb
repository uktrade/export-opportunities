module SortableHelper
  def sortable(object_filter, column, label, default_order, current_sort_state)
    order = if column == current_sort_state.column
              __reverse_order(current_sort_state.order) || default_order
            else
              default_order
            end

    link_to label, session[object_filter].merge(sort: { column: column, order: order }, paged: 1)
  end

  def __reverse_order(order)
    return unless %(asc desc).include? order
    order == 'asc' ? 'desc' : 'asc'
  end
end
