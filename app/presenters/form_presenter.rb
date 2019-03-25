class FormPresenter < PagePresenter
  include ActionView::Helpers::FormTagHelper
  require 'yaml'
  attr_reader :content, :description, :entries, :title, :view

  def initialize(content, process)
    @content = content
    @fields = prop(content, 'fields')
    @title = prop(@content, 'title')
    @description = prop(@content, 'description')

    if process.nil?
      @view = ''
      @entries = []
    else
      @view = process[:view]
      @entries = process[:entries]
    end

    # A little help to find the problem when things
    # aren't where they should be
    if @content.nil? && @fields.nil?
      raise "Check you have added appropriate content for #{process[:view]} and #{process[:fields]}."
    end
  end

  # Returns HTML string for rendering hidden input elements
  def hidden_fields
    fields = hidden_field_tag 'view', @view
    @entries.each_pair do |key, value|
      unless @fields.nil? || @fields.key?(key)
        fields += hidden_field_tag key, value
      end
    end
    fields.html_safe
  end

  # Return formatted data for Checkbox input component
  def input_checkbox(name)
    field = field_content(name)
    option_item(field, field_id(name), name)
  end

  # Return formatted data for Checkbox group form input
  def input_checkbox_group(name, options = [])
    field = field_content(name)
    field_name = prop(field, 'name') || name
    group = {}
    unless field.nil?
      group[:question] = prop(field, 'question')
      group[:name] = field_name
      group[:checkboxes] = options.presence || options_group(prop(field, 'options'), field_name)
    end
    group
  end

  # Return formatted data for separated datecomponent
  def input_date_month_year(name)
    field = field_content(name)
    id = field_id(name)
    {
      id: id,
      name_dd: "#{id}_dd",
      name_mm: "#{id}_mm",
      name_yy: "#{id}_yy",
      description: prop(field, 'description'),
      label: prop(field, 'label'),
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
  def input_radio(name, options = [])
    field = field_content(name)
    input = {}
    unless field.nil?
      input[:question] = prop(field, 'question')
      input[:name] = name
      input[:options] = options_group(prop(field, 'options'), name, options)
    end
    input
  end

  # Return formatted data for Select input component
  def input_select(name, options = [])
    field = field_content(name)
    input = {}
    opts = []
    unless field.nil?
      input[:id] = field_id(name)
      input[:label] = label(field, name)
      input[:name] = name
      input[:placeholder] = prop(field, 'placeholder')
      if options.present?
        # Should be we're getting data from BE controller
        opts = options
      else
        # Should be we're getting data from FE field construction
        options = prop(field, 'options') || []
        options.each do |option|
          label = value_by_key(option, :label)
          opts.push(text: label, value: clean_str(label))
        end
      end
      input[:options] = opts
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
      placeholder: prop(field, 'placeholder'),
    }
  end

  # Return formatted data for text field grouped input
  def input_text_group(name, values = [])
    field = field_content(name)
    field_name = prop(field, 'name') || name
    group = {}
    unless field.nil?
      group[:legend] = prop(field, 'label')
      group[:description] = prop(field, 'description')
      group[:description_id] = "label-description-#{name}"
      group[:label] = label(field, name)
      group[:name] = field_name
      group[:values] = values
    end
    group
  end

  # Return formatted data for Textarea component
  # (Basically same properties as input[text] )
  def input_textarea(name, attributes = {})
    input_text(name).merge(attributes)
  end

  # Return formatted data for Form label component
  def input_label(name)
    field = field_content(name)
    label(field, name)
  end

  # Return existence of form field
  def field_exists?(name)
    @fields.key?(name.to_s) || @fields.key?(name.to_sym)
  end

  private

    # Return lowercase string with alphanumeric+hyphen only.
    # Adds the current @view value, if exists.
    # e.g. "This -  [is]    a_string" into "this-is-a-string"
    def field_id(str)
      cleaned = if @view.present?
                  "#{clean_str(@view)}-#{clean_str(str)}"
                else
                  clean_str(str)
                end
      cleaned.tr('_', '-')
    end

    # Return lowercase string with alphanumeric+underscore only.
    # e.g. "This -  [is]    a_string" into "this_is_a_string"
    def clean_str(str)
      str = str.gsub(/[^\w\s]/, '').downcase
      str.gsub(/[\s]+/, '_')
    end

    # Return label data
    def label(field, name)
      id = field_id(name)
      {
        field_id: id,
        description: prop(field, 'description')&.html_safe,
        description_id: "#{id}_description",
        text: prop(field, 'label'),
      }
    end

    def options_group(content_options, name, data_options = [])
      options = []
      if content_options.present?
        # We going to try and make options with a combination of FE content.
        # Three possible options:
        # 1. Use content label + value from data_options (if available, likely to be enum on model)
        # 2. Use content label + content value
        # 3. Use content label + loop index as value
        content_options.each_with_index do |item, index|
          id = clean_str("#{name}_#{index}")
          option = option_item(item, id, name, (data_options[index] || index + 1))
          options.push(option)
        end
      else
        # Should be getting everyting from BE and expectig to pass off to form builders
        options = data_options
      end
      options
    end

    # Return radio/checkbox data
    def option_item(field, id, name, value = '0')
      item = {
        id: id,
        label: label(field, name),
        name: name,
        value: prop(field, 'value') || value,
      }
      item[:checked] = true if prop(field, 'checked')
      item[:label][:field_id] = id # Needs to be different in a group
      item
    end

    # Return property value or nil
    def prop(field, name)
      value = nil
      unless field.nil?
        value = value_by_key(field, name)
        value = value&.html_safe if value.is_a?(String)
      end
      value
    end

    # Returns form field content or empty hash
    def field_content(name)
      if field_exists?(name)
        value_by_key(@fields, name)
      else
        {}
      end
    end

    # Fix stupid Ruby handling of keys in a hash
    def value_by_key(hash, key)
      hash[key.to_s] || hash[key.to_sym]
    end
end
