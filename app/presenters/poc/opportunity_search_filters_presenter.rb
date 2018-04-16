class Poc::OpportunitySearchFiltersPresenter < Poc::FormPresenter
  attr_reader :content, :description, :title

  def initialize(helpers, _filters)
    @h = helpers
    @content = get_content('app/views/poc/opportunities/_filters.yml')
    @title = prop(@content, 'title')
    @description = prop(@content, 'description')
  end

  def field_content(name)
    field = super(name)
    case name
    when 'industries'
      field['options'] = industries
    when 'countries'
      field['options'] = countries
    else
      {}
    end
    field
  end

  private

  # Need to get filters from BE code.
  # Have constructed dummy date (below) that can be put
  # through form_presenter.rb code to output filters.
  def industries
    [
      { label: 'Food and Drink', value: 'Food and Drink' },
      { label: 'Aerospace', value: 'Aerospace' },
      { label: 'Construction', value: 'construction' },
    ]
  end

  def countries
    [
      { label: 'England', value: 'england' },
      { label: 'Scotland', value: 'scotland' },
      { label: 'Wales', value: 'wales' },
    ]
  end
end
