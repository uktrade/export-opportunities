class Poc::OpportunitySearchFiltersPresenter < Poc::FormPresenter
  attr_reader :selected_list, :unfiltered_search_url

  def initialize(content, filters, search)
    super(content, {})
    @filters = filters
    @search = search
    @selected_list = selected_filter_list
    @unfiltered_search_url = reset_search
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

  def reset_search
    split_url = @search.split('&')
    url = []
    split_url.each do |item|
      url.push(item) unless item.match('countries%5B%5D=') ||  item.match('sectors%5B%5D=')
    end
    url.join('&')
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

