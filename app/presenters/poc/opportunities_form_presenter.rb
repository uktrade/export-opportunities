class Poc::OpportunitiesFormPresenter < BasePresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper 
  require 'yaml'
  attr_reader :content, :description, :entries, :title, :view

  OPPORTUNITY_CONTENT_PATH = 'app/views/poc/opportunities/new/'.freeze

  def initialize(helpers, process)
    @helpers = helpers
    @entries = process[:entries]
    @content = get_content(process[:content])
    @title = prop(@content, 'title')
    @description = prop(@content, 'description')
    @view = process[:view] || 'step_1'
  end

  # Returns HTML string for rendering hidden input elements
  def hidden_fields
    fields = @helpers.hidden_field_tag 'view', @view
    @entries.each_pair do |key, value|
      unless @content['form'].nil? or @content['form'].keys.include? key
        fields += @helpers.hidden_field_tag key, value
      end
    end
    fields.html_safe
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
      label: label(field, name)
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

  # Get form field content
  def has_field?(name)
    fields = @content['form']
    fields.has_key?(name)
  end


  private

  # Return lowercae string with alphanumeric+underscore only. 
  def field_id(str)
    "#{@view}_#{str}".gsub(/[^\w]/, '').downcase
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
  def prop(field, key)
    if field.has_key?(key)
      field[key]&.html_safe
    else
      ''
    end
  end

  # Get form field content
  def field_content(name)
    fields = @content['form']
    if fields.has_key?(name)
      fields[name]
    else
      {}
    end 
  end

  # Gets form field content separated from the view
  def get_content(step)
    YAML.load_file(OPPORTUNITY_CONTENT_PATH + '_' + step + '.yml')
  end
end
