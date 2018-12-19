require 'elasticsearch'

class ElasticSearchFinder

  #
  # Searches through opportunities
  # Inputs: query, a sort order, and a time limit
  # Returns: an elasticsearch object containing opportunities
  #
  def call(query, sort, limit)
    size = Figaro.env.OPPORTUNITY_ES_MAX_RESULT_WINDOW_SIZE || 100_000
    Opportunity.__elasticsearch__.search(size: size, terminate_after: limit, query: query, sort: sort)
  end
end
