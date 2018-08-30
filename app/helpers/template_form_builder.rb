class TemplateFormBuilder < ActionView::Helpers::FormBuilder

  def input_date_month_year(method, props, attributes = {})
    legend = if props[:description].present?
               (@template.content_tag(:legend, props[:label], 'aria-describedby': props[:description_id]) +
                @template.content_tag(:p, props[:description], {
                  class: 'description',
                  id: props[:description_id]
                }))
             else
               @template.content_tag(:legend, props[:question])
             end

    day = [@object_name, method, '1i'].join('_')
    month = [@object_name, method, '2i'].join('_')
    year = [@object_name, method, '3i'].join('_')

    @template.content_tag(:fieldset,
      legend +
      (@template.label_tag(day, nil, class: 'day') do
         @template.content_tag(:span, 'Day') +
         @template.text_field_tag(day, nil, size: 2)
       end) +
      (@template.label_tag(month, nil, class: 'month') do
         @template.content_tag(:span, 'Month') +
         @template.text_field_tag(month, nil, size: 2)
       end) +
      (@template.label(year, nil, class: 'year') do
         @template.content_tag(:span, 'Year') +
         @template.text_field_tag(year, nil, size: 4)
       end),
      { class: 'field date-month-year' }
    )
  end

  def input_label(method, props)
    if props[:description].present?
      @template.label(@object_name, method, props[:text], 'aria-describedby': props[:description_id]) +
      (@template.content_tag(:p, props[:description], {
        class: 'description',
        id: props[:description_id]
       }))
    else
      @template.label(@object_name, method, props[:text])
    end
  end

  def input_radio(method, props, attributes = {})
    @template.content_tag(:fieldset,
      (@template.content_tag(:legend, props[:question])) +
      radio_options(method, props[:options]),
      { class: 'field radio-group' }
    )
  end

  def input_select(method, props, attributes = {})
    attrs = {
      placeholder: props[:placeholder]
    }.merge(attributes)
    @template.content_tag(:div,
      input_label(method, props[:label]) +
      collection_select(method, props[:options], :id, :name, {}, attrs),
      { class: 'field select' }
    )
  end

  def input_text(method, props, attributes = {})
    attrs = {
      placeholder: props[:placeholder]
    }.merge(attributes)
    @template.content_tag(:div,
      input_label(method, props[:label]) +
      (@template.text_field(@object_name, method, objectify_options(attrs))),
      { class: 'field text' }
    )
  end

  def input_textarea(method, props, attributes = {})
    @template.content_tag(:div,
      input_label(method, props[:label]) +
      @template.text_area(@object_name, method, objectify_options(attributes)),
      { class: 'field textarea' }
    )
  end

  def output_value(method, props, attributes = {})
    attributes = attributes.merge({ disabled: true, value: props[:value] })
    output = if attributes[:multiple].present?
              @template.text_area(@object_name, method, attributes)
             else
               @template.text_field(@object_name, method, attributes)
             end
    @template.content_tag(:div,
      input_label(method, props) +
      output,
      { class: 'field output' }
    )
  end

  private

  def radio_options(method, collection)
    collection_radio_buttons(method, collection, :id, :name) do |option|
      @template.content_tag(:div,
        option.radio_button +
        option.label,
        { class: 'field radio' }
      )
    end
  end

end
