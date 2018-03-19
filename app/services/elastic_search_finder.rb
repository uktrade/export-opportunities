require 'elasticsearch'

class ElasticSearchFinder
  def call(query, sort)
    Opportunity.__elasticsearch__.search(size: 100_000, query: query, sort: sort)
  end
end
