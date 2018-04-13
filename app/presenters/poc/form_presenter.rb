class Poc::FormPresenter < Poc::BasePresenter
  include ActionView::Helpers::FormTagHelper
  require 'yaml'

  # Returns HTML string for rendering hidden input elements
  def hidden_fields
    fields = hidden_field_tag 'view', @view
    @entries.each_pair do |key, value|
      unless @content['form'].nil? || @content['form'].keys.include?(key)
        fields += hidden_field_tag key, value
      end
    end
    fields.html_safe
  end

  # Return formatted data for Checkbox input component
  def input_checkbox(name)
    field = field_content(name)
    option_item(field, name)
  end

  # Return formatted data for Checkbox group form input
  def input_checkbox_group(name)
    content = field_content(name)
    group = {}
    unless content.nil?
      group[:question] = prop(content, 'question')
      group[:name] = name
      group[:checkboxes] = options_group(prop(content, 'options'), name)
    end
    group
  end

  # Return formatted data for Date Selector component
  def input_date_selector(name)
    content = field_content(name)
    id = field_id(name)
    {
      id: id,
      name_dd: "#{id}_dd",
      name_mm: "#{id}_mm",
      name_yy: "#{id}_yy",
      description: prop(content, 'description'),
      text: prop(content, 'label'),
    }
  end

  # Return formatted data for Multi Currency component
  def input_multi_currency_amount(name)
    content = field_content(name)
    id = field_id(name)
    {
      id: id,
      id_dd: "#{id}_dd",
      id_mm: "#{id}_mm",
      id_yy: "#{id}_yy",
      name: name,
      name_dd: "#{name}_dd",
      name_mm: "#{name}_mm",
      name_yy: "#{name}_yy",
      description: prop(content, 'description'),
      text: prop(content, 'label'),
    }
  end

  # Return formatted data for Radio input component
  def input_radio(name)
    content = field_content(name)
    input = {}
    unless content.nil?
      input[:question] = prop(content, 'question')
      input[:name] = name
      input[:options] = options_group(prop(content, 'options'), name)
    end
    input
  end

  # Return formatted data for Text input component
  def input_text(name)
    content = field_content(name)
    id = field_id(name)
    {
      id: id,
      name: name,
      label: label(content, name),
    }
  end

  # Return formatted data for Textarea component
  # (Basically same properties as input[text] )
  def input_textarea(name)
    input_text(name)
  end

  # Return formatted data for Form label component
  def input_label(name)
    content = field_content(name)
    label(content, name)
  end

  # Return existence of form field
  def field_exists?(name)
    fields = @content['form']
    fields.key?(name) || fields.key?(name.to_sym)
  end

  private

  # Return lowercase string with alphanumeric+hyphen only.
  # e.g. "This -  is    a string" into "this-is-a-string"
  def field_id(str)
    clean_str("#{@view} #{str}").gsub("_", "-")
  end

  # Return lowercase string with alphanumeric+underscore only.
  # e.g. "This - is    a string" into "this_is_a_string"
  def clean_str(str)
    str = str.gsub(/[^\w\s]/, '').downcase
    str.gsub(/[\s]+/, '_')
  end

  # Return label data
  def label(field, name)
    id = field_id(name)
    {
      field_id: id,
      description: prop(field, 'description'),
      description_id: "#{id}_description",
      placeholder: prop(field, 'placeholder'),
      text: prop(field, 'label'),
    }
  end

  # Return label data
  def label(field, name)
    id = field_id(name)
    {
      field_id: id,
      description: prop(field, 'description')&.html_safe,
      description_id: "#{id}_description",
      placeholder: prop(field, 'placeholder'),
      text: prop(field, 'label'),
    }
  end

  def options_group(group, name)
    options = []
    group.each_with_index do |item, index|
      id = clean_str("#{name}_#{index}")
      option = option_item(item, id, name)
      value = prop(item, 'value')
      if value.nil? || value.empty?
        option[:value] = index + 1
      end

      options.push(option)
    end
    options
  end

  # Return radio/checkbox data
  def option_item(field, id, name)
    item = {
      id: id,
      label: label(field, name),
      name: name,
      selected: false, # TODO: How to know it is selected?
      value: prop(field, 'value'),
    }

    item[:label][:field_id] = id # Needs to be different in a group
    item
  end

  # Return property value or nil
  def prop(field, name)
    value = nil
    unless field.nil?
      if field.key?(name)
        value = field[name]
      elsif field.key?(name.to_sym)
        value = field[name.to_sym]
      end

      if value.is_a?(String)
        value = value&.html_safe
      end
    end
    value
  end

  # Get form field content
  def field_content(name)
    fields = @content['form']
    if fields.key?(name) || fields.key?(name.to_sym)
      fields[name]
    else
      {}
    end
  end

  # Gets form field content separated from the view
  def get_content(file)
    YAML.load_file(file)
  end
end
