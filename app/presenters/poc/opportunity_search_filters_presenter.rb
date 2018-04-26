class Poc::OpportunitySearchFiltersPresenter < Poc::FormPresenter
  attr_reader :selected_list

  def initialize(content, filters)
    super(content, {})
    @filters = filters
    @selected_list = selected_filter_list
  end

  def field_content(name)
    field = super(name)
    case name
    when 'industries'
      field['options'] = format_options(@filters[:sectors])
      field['name'] = @filters[:sectors][:name]
    when 'countries'
      field['options'] = format_options(@filters[:countries])
      field['name'] = @filters[:countries][:name]
    else
      {}
    end
    field
  end

  def selected_filter_list
    selected = []
    @filters.each do |filter|
      if filter[1].key?(:selected) && filter[1][:selected].length > 0
        filter[1][:options].each do |option|
          if filter[1][:selected].include? option[:slug]
            selected.push option[:name]
          end
        end
      end
    end
    selected
  end

  def unfiltered_search_url
    puts request.original_url
  end

  private

  def format_options(field = {})
    options = []
    field[:options].each do |option|
      formatted_option = {
        'label': option['name'],
        'value': option['slug'],
      }

      if field[:selected].include? option['slug']
        formatted_option[:checked] = 'true'
      end

      options.push(formatted_option)
    end
    options
  end
end

