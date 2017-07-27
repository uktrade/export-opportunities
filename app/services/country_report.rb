class CountryReport
  attr_accessor :opportunities_published
  attr_accessor :responses
  attr_accessor :name
  attr_accessor :country_id
  attr_accessor :opportunities_published_target
  attr_accessor :responses_target

  def initialize
    @opportunities_published = []
    @responses = []
  end

  def call(country_id, opportunities_published, responses, name, opportunities_published_target, responses_target)
    @country_id = country_id
    @opportunities_published << opportunities_published
    @responses << responses
    @name = name
    @opportunities_published_target = opportunities_published_target
    @responses_target = responses_target
    self
  end
end
