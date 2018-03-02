class Poc::OpportunitiesFormPresenter < BasePresenter
  require 'yaml'
  attr_reader :view, :fields, :entries

  OPPORTUNITY_CONTENT_PATH = 'app/views/poc/opportunities/new/'.freeze

  def initialize(helpers, process)
    @helpers = helpers
    @entries = process[:entries]
    @fields = form_field_content process[:fields]
    @view = process[:view] || 'step_1'
  end

  # Returns HTML string for rendering hidden input elements
  def hidden_fields
    fields = @helpers.hidden_field_tag 'view', @view
    @entries.each_pair do |key, value|
      unless @fields.keys.include? key
        fields += @helpers.hidden_field_tag key, value
      end
    end
    fields.html_safe
  end

  # Simplify syntax for rendering field label content
  def label(name)
    field_property_value(name, 'label')
  end

  # Simplify syntax for rendering field description content
  def description(name)
    field_property_value(name, 'description')
  end

  # Safely get field property value
  private def field_property_value(fieldname, key)
    field = @fields[fieldname]
    if field.nil?
      "Cannot find #{key} for field '#{fieldname}'"
    else
      field[key]&.html_safe
    end
  end

  # Gets form field content separated from the view
  private def form_field_content(step)
    case step
    when 'step_2'
      YAML.load_file(OPPORTUNITY_CONTENT_PATH + '_step_2.yml')
    when 'step_3.1'
      YAML.load_file(OPPORTUNITY_CONTENT_PATH + '_step_3.1.yml')
    when 'step_3.2'
      YAML.load_file(OPPORTUNITY_CONTENT_PATH + '_step_3.2.yml')
    when 'step_3.3'
      YAML.load_file(OPPORTUNITY_CONTENT_PATH + '_step_3.3.yml')
    else
      YAML.load_file(OPPORTUNITY_CONTENT_PATH + '_step_1.yml')
    end
  end
end
