class Poc::OpportunitiesFormPresenter < BasePresenter
  require 'yaml'
  attr_reader :view, :fields, :entries

  OPPORTUNITY_CONTENT_PATH = 'app/views/poc/opportunities/new/'

  def initialize(helpers, process)
    @helpers = helpers
    @entries = process[:entries]
    @fields = form_field_content process[:fields]
    @view = process[:view] || 'step_1'
  end

  def hidden_fields(current)
    fields = @helpers.hidden_field_tag 'view', @view
    @entries.each_pair do |key, value|
      unless @fields.keys.include? key
        fields += @helpers.hidden_field_tag key, value
      end
    end
    return fields
  end

  def label(name)
    begin
      @fields[name]['label'].html_safe
    rescue
      "Cannot find label for field '#{name}'"
    end
  end

  def description(name)
    begin
      @fields[name]['description'].html_safe
    rescue
      "Cannot find description for field '#{name}'"
    end
  end

  def form_field_content(step)
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
