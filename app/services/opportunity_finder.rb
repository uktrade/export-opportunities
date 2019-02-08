class OpportunityFinder
  def call(id)
    opportunity = Opportunity.find(id)

    Success.new(opportunity)
  rescue ActiveRecord::RecordNotFound => e
    Error.new(e.message, :not_found)
  end

  class Success
    attr_reader :data
    def initialize(data)
      @data = data
    end

    def success?
      true
    end
  end

  class Error
    attr_reader :error, :code
    def initialize(error, code)
      @error = error
      @code = code
    end

    def success?
      false
    end
  end
end
