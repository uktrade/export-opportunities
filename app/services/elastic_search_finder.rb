require 'elasticsearch'

class ElasticSearchFinder
  def call(query, sort)
    Opportunity.__elasticsearch__.search(size: ENV.fetch('OPPORTUNITY_ES_MAX_RESULT_WINDOW_SIZE', 100_000.to_s), query: query, sort: sort)
  end
end
