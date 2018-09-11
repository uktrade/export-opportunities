require 'elasticsearch'

class ElasticSearchFinder
  def call(query, sort, limit)
    Opportunity.__elasticsearch__.search(size: Figaro.env.OPPORTUNITY_ES_MAX_RESULT_WINDOW_SIZE ? Figaro.env.OPPORTUNITY_ES_MAX_RESULT_WINDOW_SIZE : 100_000, terminate_after: limit, query: query, sort: sort)
  end
end
