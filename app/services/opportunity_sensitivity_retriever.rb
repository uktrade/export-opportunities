require 'opps_sensitivity_connector'

class OpportunitySensitivityRetriever
  def call(opportunity)
    OppsSensitivityConnector.new.call(opportunity.title)
  end
end
