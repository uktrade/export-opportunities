class Poc::OpportunityFormPresenter < Poc::FormPresenter
  attr_reader :content, :description, :entries, :title, :view

  OPPORTUNITY_CONTENT_PATH = 'app/views/poc/opportunities/new/'.freeze

  def initialize(process)
    @entries = process[:entries]
    @content = get_content(OPPORTUNITY_CONTENT_PATH + '_' + process[:content] + '.yml')
    @title = prop(@content, 'title')
    @description = prop(@content, 'description')
    @view = process[:view] || 'step_1'
  end
end
