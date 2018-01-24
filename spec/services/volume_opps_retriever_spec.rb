require 'rails_helper'

RSpec.describe VolumeOppsRetriever do
  it 'retrieves opps in volume' do
    VolumeOppsRetriever.new.call
  end
end
