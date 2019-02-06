require 'hawk'
require 'json'
require 'rails_helper'
require 'socket'

def auth_header(ts, key_id, secret_key, uri, payload)
  credentials = {
    id: key_id,
    key: secret_key,
    algorithm: 'sha256',
  }
  return Hawk::Client.build_authorization_header(
    credentials: credentials,
    ts: ts,
    method: 'GET',
    request_uri: uri,
    host: 'test.host',
    port: '443',
    content_type: '',
    payload: payload,
  )
end

RSpec.describe Api::ActivityStreamController, type: :controller, focus: true do
  describe 'GET feed controller if activity_stream is not enabled' do
    it 'responds with a 403 error' do
      get :enquiries, params: { format: :json }
      expect(response.status).to eq(403)
      expect(response.body).to eq(%({"message":"Activity Stream is disabled"}))
    end
  end

  describe 'GET feed controller if activity_stream is enabled' do
    before :each do
      allow(Figaro.env).to receive('ACTIVITY_STREAM_ENABLED').and_return('true')
    end

    it 'responds with a 401 error if connecting from unauthorized IP' do
      # The whitelist is 0.0.0.0, and we reject all requests that don't have
      # 0.0.0.0 as the second-to-last IP in X-Fowarded-For, as this isn't
      # spoofable in PaaS
      get :enquiries, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))

      @request.headers['X-Forwarded-For'] = '1.2.3.4'
      get :enquiries, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))

      @request.headers['X-Forwarded-For'] = '0.0.0.0'
      get :enquiries, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))

      @request.headers['X-Forwarded-For'] = '1.2.3.4, 0.0.0.0'
      get :enquiries, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))

      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4, 123.123.123'
      get :enquiries, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))

      @request.headers['X-Forwarded-For'] = '1.2.3.4, 123.123.123, 0.0.0.0'
      get :enquiries, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))
    end

    it 'responds with a 401 error if Authorization header is not set' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      get :enquiries, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Authorization header is missing"}))
    end

    it 'responds with a 401 if Authorization header in invalid format' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = 'Hawk'  # Should have a space after
      get :enquiries, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = 'Hawk  '  # Should not have two spaces after
      get :enquiries, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = 'Hawk a'
      get :enquiries, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = 'Hawk b='
      get :enquiries, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = 'Hawk b="'
      get :enquiries, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = 'Hawk b="a" c="d"'  # Should have commas
      get :enquiries, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = 'Hawk, b="a", c="d"'  # Should not have comma after Hawk
      get :enquiries, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = 'Hawk b="a",c="d"'  # Should have space after comma
      get :enquiries, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = 'Hawk b="a", c="d" '  # Should not have trailing space
      get :enquiries, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = 'Hawk B="a"'  # Keys must be lower case
      get :enquiries, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      ).sub('Hawk ', 'AWS ')
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      ).sub('Hawk ', ' Hawk ')  # Should not have leading space
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      ).sub('Hawk ', '')
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      ).sub('Hawk ', ', ')
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))

      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      ).sub('Hawk ', '", ')
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid header"}))
    end

    it 'responds with a 401 if Authorization header is set, but timestamped 61 seconds in the past' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i - 61,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      )
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Stale ts"}))
    end

    it 'responds with a 401 if Authorization header misses ts' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = 'Hawk mac="a", hash="b", nonce="c", id="d"'
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing ts")
    end

    it 'responds with a 401 if Authorization header has non integer ts' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = 'Hawk ts="a", mac="a", hash="b", nonce="c", id="d"'
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Invalid ts")
    end

    it 'responds with a 401 if Authorization header has empty ts' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = 'Hawk ts="", mac="a", hash="b", nonce="c", id="d"'
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing ts")
    end

    it 'responds with a 401 if Authorization header misses mac' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = 'Hawk ts="1", hash="b", nonce="c", id="d"'
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing mac")
    end

    it 'responds with a 401 if Authorization header has empty mac' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = 'Hawk ts="1", mac="", hash="b", nonce="c", id="d"'
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing mac")
    end

    it 'responds with a 401 if Authorization header misses hash' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = 'Hawk ts="1", mac="a", nonce="c", id="d"'
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing hash")
    end

    it 'responds with a 401 if Authorization header has empty hash' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = 'Hawk ts="1", mac="a", hash="", nonce="c", id="d"'
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing hash")
    end

    it 'responds with a 401 if Authorization header misses nonce' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = 'Hawk ts="1", mac="a", id="d"'
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing hash")
    end

    it 'responds with a 401 if Authorization header has empty nonce' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = 'Hawk ts="1", mac="a", nonce="", id="d"'
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing hash")
    end

    it 'responds with a 401 if Authorization header misses id' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = 'Hawk ts="1", mac="a", hash="b", nonce="c"'
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing id")
    end

    it 'responds with a 401 if Authorization header has empty id' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = 'Hawk ts="1", mac="a", hash="b", nonce="c", id=""'
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing id")
    end

    it 'responds with a 401 if Authorization header uses incorrect key ID' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID + 'something-incorrect',
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      )
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Unidentified id"}))
    end

    it 'responds with a 401 if Authorization header uses incorrect key' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY + 'something-incorrect',
        activity_stream_enquiries_path,
        '',
      )
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Invalid mac")
    end

    it 'responds with a 401 if Authorization header uses incorrect payload' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        'something-incorrect',
      )
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Invalid hash")
    end

    it 'responds with a 401 if header is reused' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      )
      get :enquiries, params: { format: :json }

      expect(response.status).to eq(200)

      get :enquiries, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid nonce"}))
    end

    it 'bubbles an error if Authorization header is correct, but Redis is down' do
      # This test deliberately does not mock the Redis class to raise an Error.
      # This might be brittle with respect to internals of the Redis class, but
      # this is chosen as better than assuming that Redis behaves a certain way
      # in the case of socket errors, since, within reason, it's better for the
      # test to fail too much than too little.
      allow_any_instance_of(Socket).to receive(:connect_nonblock).and_raise(SocketError)
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      )
      begin
        get :enquiries, params: { format: :json }
      rescue SocketError => ex
      end
      expect(ex.backtrace.to_s).to include('/redis/')
    end

    it 'responds with no items if Authorization header is set and correct' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      )
      get :enquiries, params: { format: :json }

      expect(JSON.parse(response.body)['orderedItems']).to eq([])
      expect(response.headers['Content-Type']).to eq('application/activity+json')
    end

    it 'does not have any entry elements if an enquiry made without a company number' do
      create(:enquiry, company_house_number: nil)

      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      )
      get :enquiries, params: { format: :json }

      expect(JSON.parse(response.body)['orderedItems']).to eq([])
    end

    it 'does not have any entry elements if an enquiry made without a blank company house number' do
      create(:enquiry, company_house_number: '')

      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      )
      get :enquiries, params: { format: :json }

      expect(JSON.parse(response.body)['orderedItems']).to eq([])
    end

    it 'has a single entry element if a company has been made with a company house number' do
      enquiry = nil
      country_1 = create(:country, name: 'a')
      country_2 = create(:country, name: 'b')
      Timecop.freeze(Time.utc(2008, 9, 1, 12, 1, 2)) do
        enquiry = create(:enquiry, company_house_number: '123')
        enquiry.opportunity.countries = [country_1, country_2]
      end

      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      )
      get :enquiries, params: { format: :json }
      feed_hash = JSON.parse(response.body)

      items = feed_hash['orderedItems']
      expect(items.length).to eq(1)

      item =  items[0]
      expect(item['id']).to eq("dit:exportOpportunities:Enquiry:#{enquiry.id}:Create")
      expect(item['type']).to eq('Create')
      expect(item['object']['published']).to eq('2008-09-01T12:01:02+00:00')
      expect(item['actor'][0]['type']).to include('Organization')
      expect(item['actor'][0]['type']).to include('dit:Company')
      expect(item['actor'][0]['dit:companiesHouseNumber']).to eq('123')
      expect(item['object']['type']).to include('Document')
      expect(item['object']['type']).to include('dit:exportOpportunities:Enquiry')
      expect(item['object']['id']).to eq("dit:exportOpportunities:Enquiry:#{enquiry.id}")
      expect(item['object']['url']).to eq("http://test.host/admin/enquiries/#{enquiry.id}")
      expect(item['object']['inReplyTo']['dit:country'][0]).to eq('a')
      expect(item['object']['inReplyTo']['dit:country'][1]).to eq('b')
    end

    it 'has a two entries, in date order, if two enquiries have been made with company house numbers' do
      enquiry_1 = nil
      Timecop.freeze(Time.utc(2008, 9, 1, 12, 1, 3)) do
        enquiry_1 = create(:enquiry, company_house_number: '123')
      end

      enquiry_2 = nil
      Timecop.freeze(Time.utc(2008, 9, 1, 12, 1, 2)) do
        enquiry_1 = create(:enquiry, company_house_number: '124')
      end

      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      )
      get :enquiries, params: { format: :json }
      feed_hash = JSON.parse(response.body)

      items = feed_hash['orderedItems']
      expect(items.length).to eq(2)

      elastic_search_bulk_1 = items[0]
      expect(elastic_search_bulk_1['object']['published']).to eq('2008-09-01T12:01:02+00:00')

      elastic_search_bulk_2 =  items[1]
      expect(elastic_search_bulk_2['object']['published']).to eq('2008-09-01T12:01:03+00:00')
    end

    it 'in ID order if two enquiries are made at the same time' do
      enquiry_1 = nil
      Timecop.freeze(Time.utc(2008, 9, 1, 12, 1, 2)) do
        enquiry_1 = create(:enquiry, company_house_number: '123', id: 2345)
      end

      enquiry_2 = nil
      Timecop.freeze(Time.utc(2008, 9, 1, 12, 1, 2)) do
        enquiry_1 = create(:enquiry, company_house_number: '124', id: 2344)
      end

      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      )
      get :enquiries, params: { format: :json }
      feed_hash = JSON.parse(response.body)

      items = feed_hash['orderedItems']

      elastic_search_bulk_1 = items[0]
      expect(elastic_search_bulk_1['actor'][0]['dit:companiesHouseNumber']).to eq('124')

      elastic_search_bulk_2 =  items[1]
      expect(elastic_search_bulk_2['actor'][0]['dit:companiesHouseNumber']).to eq('123')
    end

    it 'is paginated with a link element if there are MAX_PER_PAGE enquiries' do
      country_1 = create(:country)
      country_2 = create(:country)

      # Creating records takes quite a while. Stub for a quicker test
      stub_const("MAX_PER_PAGE", 20)
      Timecop.freeze(Time.utc(2008, 9, 1, 12, 1, 2, 344590)) do
        for i in 1..21 do
          enquiry = create(:enquiry, company_house_number: i.to_s, id:(2923 + i))
          enquiry.opportunity.countries = [country_1, country_2]
        end
      end

      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        activity_stream_enquiries_path,
        '',
      )
      get :enquiries, params: { format: :json }
      feed_hash_1 = JSON.parse(response.body)

      expect(feed_hash_1['orderedItems'].length).to eq(20)
      expect(feed_hash_1.key?('next')).to eq(true)
      expect(feed_hash_1['next']).to include('?search_after=1220270462.344590_2943')

      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        '/api/activity_stream/enquiries?search_after=1220270462.344590_2943',
        '',
      )
      get :enquiries, params: { format: :json, search_after: '1220270462.344590_2943' }
      feed_hash_2 = JSON.parse(response.body)
      expect(feed_hash_2.key?('next')).to eq(true)
      expect(feed_hash_2['orderedItems'][0]['id']).to eq('dit:exportOpportunities:Enquiry:2944:Create')

      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        '/api/activity_stream/enquiries?search_after=1220270462.344590_2944',
        '',
      )
      get :enquiries, params: { format: :json, search_after: '1220270462.344590_2944' }
      feed_hash_3 = JSON.parse(response.body)
      expect(feed_hash_3.key?('next')).to eq(false)
      expect(feed_hash_3['orderedItems']).to eq([])
    end
  end
end
