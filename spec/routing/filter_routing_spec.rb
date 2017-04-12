require 'rails_helper'

RSpec.describe 'filter routing', type: :routing do
  it 'should handle single countries' do
    expect(get('/country/france')).to route_to(controller: 'opportunities', action: 'index', countries: 'france')
  end

  it "shouldn't route to multiple countries" do
    not_found = { controller: 'errors', action: 'not_found', path: 'country/brazil,belgium' }
    expect(get('/country/brazil,belgium')).to route_to(not_found)
  end

  it 'should handle single sectors' do
    expect(get('/industry/aerospace')).to route_to(controller: 'opportunities', action: 'index', sectors: 'aerospace')
  end

  it "shouldn't route to multiple industries" do
    not_found = { controller: 'errors', action: 'not_found', path: 'industry/aerospace,skincare' }
    expect(get('/industry/aerospace,skincare')).to route_to(not_found)
  end

  it 'should handle single types' do
    expect(get('/sector/public-sector')).to route_to(controller: 'opportunities', action: 'index', types: 'public-sector')
  end

  it "shouldn't route to multiple types" do
    not_found = { controller: 'errors', action: 'not_found', path: 'sector/public-sector,private-sector' }
    expect(get('/sector/public-sector,private-sector')).to route_to(not_found)
  end

  it 'should handle single values' do
    expect(get('/value/over-100k')).to route_to(controller: 'opportunities', action: 'index', values: 'over-100k')
  end

  it "shouldn't route to multiple values" do
    not_found = { controller: 'errors', action: 'not_found', path: 'value/over-100k,under-100k' }
    expect(get('/value/over-100k,under-100k')).to route_to(not_found)
  end
end
