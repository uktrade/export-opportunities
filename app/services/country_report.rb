class CountryReport
  attr_accessor :opportunities_published
  attr_accessor :enquiries
  attr_accessor :name
  attr_accessor :country_id
  attr_accessor :opportunities_published_target
  attr_accessor :enquiries_target

  def initialize
    @opportunities_published = []
  end

  def call(country_id, opportunities_published, enquiries, name, opportunities_published_target, enquiries_target)
    @country_id = country_id
    @opportunities_published << opportunities_published
    @enquiries = enquiries
    @name = name
    @opportunities_published_target = opportunities_published_target
    @enquiries_target = enquiries_target
    self
  end
end
