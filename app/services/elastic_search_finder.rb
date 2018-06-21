require 'elasticsearch'

class ElasticSearchFinder
  def call(query, sort)
    Opportunity.__elasticsearch__.search(size: Figaro.env.OPPORTUNITY_ES_MAX_RESULT_WINDOW_SIZE ? Figaro.env.OPPORTUNITY_ES_MAX_RESULT_WINDOW_SIZE : 100_000, query: query, sort: sort)
  end
end
