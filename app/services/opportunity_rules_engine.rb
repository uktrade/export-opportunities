require 'rules_engine'

class OpportunityRulesEngine
  def call(opportunity)
    RulesEngine.new.call(opportunity)
  end
end
