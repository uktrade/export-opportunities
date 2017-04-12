module ApplicationHelper
  def present_html_or_formatted_text(text)
    return '' unless text.present?
    return simple_format(text) if HTMLComparison.new.tags?(text)
    sanitize(text)
  end

  def promote_elements_to_front_of_array(array, selected_elements = [])
    selected_elements + (array - selected_elements)
  end
end
