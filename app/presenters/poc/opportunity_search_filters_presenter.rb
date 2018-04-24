class Poc::OpportunitySearchFiltersPresenter < Poc::FormPresenter
  attr_reader :content, :description, :title

  def initialize(content, filters)
    super(content, {})
    @filters = filters
  end

  def field_content(name)
    field = super(name)
    case name
    when 'industries'
      field['options'] = format_options(@filters[:sectors][:options])
      field['name'] = @filters[:sectors][:name]
    when 'countries'
      field['options'] = format_options(@filters[:countries][:options])
      field['name'] = @filters[:countries][:name]
    else
      {}
    end
    field
  end

  private

  def format_options(options = {})
    options_array = []
    options.each do |option|
      options_array.push(
        'label': option['name'],
        'value': option['slug']
      )
    end
    options_array
  end
end
