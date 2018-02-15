require 'rails_helper'

RSpec.describe VolumeOppsRetriever do
  it 'retrieves opps in volume' do
    skip('refactor to make it fetch a few opps')
    editor = create(:editor)
    country = create(:country, id: '11')
    create(:sector, id: '2')
    create(:type, id: '3')
    create(:value, id: '3')
    create(:service_provider, id: '5', country: country)

    VolumeOppsRetriever.new.call(editor)
  end
end
