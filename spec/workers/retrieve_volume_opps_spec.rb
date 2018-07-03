require 'rails_helper'

RSpec.describe RetrieveVolumeOpps, :elasticsearch, :commit, sidekiq: :inline do
  it 'quality checks opps when there are some' do

  end

  it 'doesnt do anything when there are no opps to score' do

  end

  it 're-indexes results in ES when opps scoring is done' do
    
  end
end
