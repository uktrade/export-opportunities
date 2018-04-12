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
    id = clean_str(name)
    {
      id: id,
      name: name,
      label: label(field, name),
    }
  end

  # TODO...
  # Return formatted data for Checkbox group form input
  def input_checkbox_group(name)
    field = field_content(name)
    input = {}
    unless field.nil?
      input[:question] = prop(field, 'question')
      input[:name] = name
      input[:checkboxes] = checkboxes(field['options'], name)
    end
    input
  end

  # Return formatted data for Date Selector component
  def input_date_selector(name)
    field = field_content(name)
    id = field_id(name)
    {
      id: id,
      name_dd: "#{id}_dd",
      name_mm: "#{id}_mm",
      name_yy: "#{id}_yy",
      description: prop(field, 'description'),
      text: prop(field, 'label'),
    }
  end

  # Return formatted data for Multi Currency component
  def input_multi_currency_amount(name)
    field = field_content(name)
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
      description: prop(field, 'description'),
      text: prop(field, 'label'),
    }
  end

  # Return formatted data for Radio input component
  def input_radio(name)
    field = field_content(name)
    input = {}
    unless field.nil?
      input[:question] = prop(field, 'question')
      input[:name] = name
      input[:options] = radios(field['options'], name)
    end
    input
  end

  # Return formatted data for Text input component
  def input_text(name)
    field = field_content(name)
    id = field_id(name)
    {
      id: id,
      name: name,
      label: label(field, name),
    }
  end

  # Return formatted data for Textarea component
  # (Basically same properties as input[text] )
  def input_textarea(name)
    input_text(name)
  end

  # Return formatted data for Form label component
  def input_label(name)
    field = field_content(name)
    label(field, name)
  end

  # Return existence of form field
  def field_exists?(name)
    fields = @content['form']
    fields.key?(name)
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

  # Return formatted radios with labels data
  def checkboxes(options, name)
    checkboxes = []
    options.each_with_index do |option, index|
      id = clean_str("#{name}_#{index}")
      checkbox_label = label(option, name)
      checkbox_label[:field_id] = id
      checkbox = {
        id: id,
        value: option.key?('value') ? clean_str(option['value']) : index + 1, # Avoid value==0
        checked: false, # TODO: How to know it is selected?
        label: checkbox_label,
      }
      checkboxes.push(checkbox)
    end
    checkboxes
  end

  # Return formatted radios with labels data
  def radios(options, name)
    radios = []
    options.each_with_index do |option, index|
      id = field_id("#{name}_#{index}")
      radio_label = label(option, name)
      radio_label[:field_id] = id
      radio = {
        id: id,
        value: option.key?('value') ? clean_str(option['value']) : index + 1, # Avoid value==0
        checked: false, # TODO: How to know it is selected?
        label: radio_label,
      }
      radios.push(radio)
    end
    radios
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

  # Return formatted radios with labels data
  def radios(options, name)
    radios = []
    options.each_with_index do |option, index|
      id = field_id("#{name}_#{index}")
      radio_label = label(option, name)
      radio_label[:field_id] = id
      radio = {
        id: id,
        value: index + 1, # Avoid value==0
        checked: false, # TODO: How to know it is selected?
        label: radio_label,
      }
      radios.push(radio)
    end
    radios
  end

  # Return property value or empty string
  def prop(field, name)
    if field.key?(name)
      field[name]&.html_safe
    elsif field.key?(name.to_sym)
      field[name.to_sym]&.html_safe
    else
      ''
    end
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
