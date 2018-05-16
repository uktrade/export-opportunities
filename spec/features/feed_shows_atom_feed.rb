require 'rails_helper'
require 'uri'

feature 'feed' do
  scenario 'is valid XML and has an Atom feed element as its root' do
    visit '/api/feed?shared_secret=' + URI::encode('?[!@$%^%')

    xml_hash = Hash.from_xml(page.body)
    feed = xml_hash['feed']

    expect(feed['xmlns']).to eq('http://www.w3.org/2005/Atom')
  end

  scenario 'returns a paginated feed' do
      enquiries = []
      for i in 1..21 do
        enquiries << create(:enquiry, company_house_number: i.to_s)
      end

      visit '/api/feed?shared_secret=' + URI::encode('?[!@$%^%')
      xml_hash_1 = Hash.from_xml(page.body)
      feed_1 = xml_hash_1['feed']
      expect(feed_1['entry'].length).to eq(20)
      expect(feed_1['link']['rel']).to eq('next')
      href = feed_1['link']['href']

      visit href
      xml_hash_2 = Hash.from_xml(page.body)
      feed_2 = xml_hash_2['feed']

      expect(feed_2.key?('link')).to eq(false)
      expect(feed_2['entry'].length).to eq(4)

      for enquiry in enquiries do
        Enquiry.destroy(enquiry.id)
      end
    end
end
