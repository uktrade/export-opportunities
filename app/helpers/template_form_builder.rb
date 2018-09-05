class TemplateFormBuilder < ActionView::Helpers::FormBuilder
  def input_checkbox_group(method, props)
    @template.content_tag(
      :fieldset,
      @template.content_tag(:legend, props[:question]) + checkbox_collection(method, props[:checkboxes]),
      class: 'field checkbox-group'
    )
  end

  def input_date_month_year(method, props)
    legend = if props[:description].present?
               (@template.content_tag(:legend, props[:label], 'aria-describedby': props[:description_id]) +
                @template.content_tag(:p, props[:description],
                  class: 'description',
                  id: props[:description_id]))
             else
               @template.content_tag(:legend, props[:question])
             end

    day_name = "#{@object_name}[#{method}(3i)]"
    day_value = nil

    month_name = "#{@object_name}[#{method}(2i)]"
    month_value = nil

    year_name = "#{@object_name}[#{method}(1i)]"
    year_value = nil

    date = @object[method]
    if date.present?
      day_value = date.day
      month_value = date.month
      year_value = date.year
    end
    
    @template.content_tag(
      :fieldset,
      legend +
      (@template.label_tag(day_name, nil, class: 'day') do
         @template.content_tag(:span, 'Day') +
         @template.text_field_tag(day_name, day_value, size: 2)
       end) +
      (@template.label_tag(month_name, nil, class: 'month') do
         @template.content_tag(:span, 'Month') +
         @template.text_field_tag(month_name, month_value, size: 2)
       end) +
      (@template.label(year_name, nil, class: 'year') do
         @template.content_tag(:span, 'Year') +
         @template.text_field_tag(year_name, year_value, size: 4)
       end),
      class: 'field date-month-year'
    )
  end

  def input_label(method, props)
    if props[:description].present?
      @template.label(@object_name, method, props[:text], 'aria-describedby': props[:description_id]) +
        @template.content_tag(:p, props[:description],
          class: 'description',
          id: props[:description_id])
    else
      @template.label(@object_name, method, props[:text])
    end
  end

  def input_radio(method, props)
    @template.content_tag(:fieldset,
      @template.content_tag(:legend, props[:question]) +
      radio_collection(method, props[:options]),
      class: 'field radio-group')
  end

  def input_select(method, props, attributes = {})
    config = {}

    # Set a default selected option from passed attribute
    if @object[method].nil? && attributes[:default].present?
      config.merge!(selected: attributes[:default])
    end

    # Merge remaining attributes with anything we want to take from props
    attributes.merge!({
      placeholder: props[:placeholder],
    })

    # Construct the field
    @template.content_tag(
      :div,
      input_label(method, props[:label]) +
      collection_select(method, props[:options], :id, :name, config, attributes),
      class: 'field select')
  end

  def input_text(method, props, attributes = {})
    attrs = {
      placeholder: props[:placeholder],
    }.merge(attributes)
    @template.content_tag(
      :div,
      input_label(method, props[:label]) +
      @template.text_field(@object_name, method, objectify_options(attrs)),
      class: 'field text'
    )
  end

  def input_textarea(method, props, attributes = {})
    @template.content_tag(
      :div,
      input_label(method, props[:label]) +
      @template.text_area(@object_name, method, objectify_options(attributes)),
      class: 'field textarea'
    )
  end

  def output_value(method, props, attributes = {})
    attributes = attributes.merge(disabled: true, value: props[:value])
    output = if attributes[:multiple].present?
               @template.text_area(@object_name, method, attributes)
             else
               @template.text_field(@object_name, method, attributes)
             end
    @template.content_tag(
      :div,
      input_label(method, props) +
      output,
      class: 'field output'
    )
  end

  private

  def radio_collection(method, collection)
    inputs = ''
    # Is there a better way to detect difference?
    if collection.class.to_s == 'Array'
      # collection is Array data constructed with content .yml file
      collection.each do |option|
        label = option[:label]
        inputs += @template.content_tag(
          :div,
          @template.radio_button(@object_name, method, option[:value]) +
            @template.label(@object_name, method, label[:text], value: option[:value]),
          class: 'field radio'
        )
      end
    else
      # collection is Value::ActiveRecord_Relation
      inputs = collection_radio_buttons(method, collection, :id, :name) do |option|
        @template.content_tag(
          :div,
          option.radio_button +
            option.label,
          class: 'field radio'
        )
      end
    end
    inputs.html_safe
  end

  def checkbox_collection(method, collection)
    collection_check_boxes(method, collection, :id, :name) do |option|
      @template.content_tag(:div,
        option.check_box +
        option.label,
        class: 'field checkbox')
    end
  end
end
