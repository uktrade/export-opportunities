require 'rails_helper'

feature 'feed' do
  scenario 'is valid XML and has an Atom feed element as its root' do
    visit '/api/feed?shared_secret=secret'

    xml_hash = Hash.from_xml(page.body)
    feed = xml_hash['feed']

    expect(feed['xmlns']).to eq('http://www.w3.org/2005/Atom')
  end
end
