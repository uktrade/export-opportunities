require 'elasticsearch'

class ElasticSearchFinder

  #
  # Searches through opportunities
  # Inputs: None 
  # Methods: #call takes as inputs: a query, a sort order, 
  #          and a max number of documents per shard (limit)
  #          and returns an elasticsearch object containing opportunities
  #
  # NOTE potential issue when using terminate_after
  # https://stackoverflow.com/questions/40423696/terminate-after-in-elasticsearch
  # "Terminate after limits the number of search hits per shard so
  # any document that may have had a hit later could also have had
  # a higher ranking(higher score) than highest ranked document returned
  # since the score used for ranking is independent of the other hits."
  #

  def call(query, sort, limit)
    size = Figaro.env.OPPORTUNITY_ES_MAX_RESULT_WINDOW_SIZE || 100_000
    Opportunity.__elasticsearch__.search(size: size, 
                                         terminate_after: limit,
                                         query: query,
                                         sort: sort)
  end
end
