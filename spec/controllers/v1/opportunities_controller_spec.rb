require 'rails_helper'

describe V1::OpportunitiesController, type: :controller do
  let(:uuid) { '0b7c3dd8-1054-4318-8b8b-fe892b6f24ef' }

  before(:each) do
    request.headers['accept'] = 'application/json'
  end

  describe '#show' do
    it 'returns 200' do
      create(:opportunity, id: uuid)

      get :show, params: { id: uuid }

      expect(response.status).to eq(200)
    end

    it 'returns the opportunity as json' do
      create :opportunity,
        id: uuid,
        title: 'Thing',
        slug: 'repudiandae-quas',
        created_at: DateTime.new(2016, 2, 22, 13, 40, 0o3).utc,
        updated_at: DateTime.new(2016, 2, 22, 13, 40, 0o3).utc,
        status: 'pending',
        teaser: 'A nostrum quia expedita est. Eligendi maxime quia voluptas fugit. Et ut aut voluptatem consectetur officia quis modi. Nihil ipsam maiores id',
        response_due_on: Date.new(2016, 2, 27),
        description: 'A nostrum quia expedita est. Eligendi maxime quia voluptas fugit. Et ut aut voluptatem consectetur officia quis modi. Nihil ipsam maiores id.Maiores sit dolor. Aut nobis mollitia. Possimus aperiam aut.',
        service_provider: create(:service_provider, name: 'Abbey Bosco'),
        contacts: [
          build(:contact, name: 'Jane Doe', email: 'jane.doe@example.com'),
          build(:contact, name: 'Joe Bloggs', email: 'joe.bloggs@example.com'),
        ]

      expected_hash = { 'opportunity' =>
        {
          'id' => uuid,
          'title' => 'Thing',
          'slug' => 'repudiandae-quas',
          'created_at' => '2016-02-22T13:40:03Z',
          'updated_at' => '2016-02-22T13:40:03Z',
          'status' => 'pending',
          'teaser' => 'A nostrum quia expedita est. Eligendi maxime quia voluptas fugit. Et ut aut voluptatem consectetur officia quis modi. Nihil ipsam maiores id',
          'response_due_on' => '2016-02-27',
          'description' => 'A nostrum quia expedita est. Eligendi maxime quia voluptas fugit. Et ut aut voluptatem consectetur officia quis modi. Nihil ipsam maiores id.Maiores sit dolor. Aut nobis mollitia. Possimus aperiam aut.',
          'service_provider' => 'Abbey Bosco',
          'contacts' => [
            { 'name' => 'Jane Doe', 'email' => 'jane.doe@example.com' },
            { 'name' => 'Joe Bloggs', 'email' => 'joe.bloggs@example.com' },
          ],
          'countries' => [],
          'sectors' => [],
          'types' => [],
          'values' => [],
        } }

      get :show, params: { id: uuid }

      expect(JSON.parse(response.body)).to include(expected_hash)
    end

    it 'returns the contacts' do
      contact = create(:contact, id: 1112, opportunity_id: uuid, name: 'Green Shatterstar', email: 'ted@friesen.biz')
      create(:opportunity, id: uuid, contacts: [contact])
      expected_hash = { 'name' => 'Green Shatterstar', 'email' => 'ted@friesen.biz' }

      get :show, params: { id: uuid }

      expect(JSON.parse(response.body)['opportunity']['contacts']).to include(expected_hash)
    end

    it 'returns the countries' do
      country = create(:country, slug: 'ratione.fugiat', name: 'Mr Speedball Skull')
      create(:opportunity, id: uuid, countries: [country])
      expected_hash = { 'slug' => 'ratione.fugiat', 'name' => 'Mr Speedball Skull' }

      get :show, params: { id: uuid }

      expect(JSON.parse(response.body)['opportunity']['countries']).to include(expected_hash)
    end

    it 'returns the sectors' do
      sector = create(:sector, id: 123, slug: 'natus-quisquam', name: 'Green Triton Thirteen')
      create(:opportunity, id: uuid, sectors: [sector])
      expected_hash = { 'slug' => 'natus-quisquam', 'name' => 'Green Triton Thirteen' }

      get :show, params: { id: uuid }

      expect(JSON.parse(response.body)['opportunity']['sectors']).to include(expected_hash)
    end

    it 'returns the types' do
      type = create(:type, id: 7, slug: 'quis.mollitia', name: 'The Granny Goodness')
      create(:opportunity, id: uuid, types: [type])
      expected_hash = { 'slug' => 'quis.mollitia', 'name' => 'The Granny Goodness' }

      get :show, params: { id: uuid }

      expect(JSON.parse(response.body)['opportunity']['types']).to include(expected_hash)
    end

    it 'returns the values' do
      value = create(:value, id: 7, slug: '100', name: '100K')
      create(:opportunity, id: uuid, values: [value])
      expected_hash = { 'slug' => '100', 'name' => '100K' }

      get :show, params: { id: uuid }

      expect(JSON.parse(response.body)['opportunity']['values']).to include(expected_hash)
    end

    context "when the opportunity doesn't exist" do
      it 'returns 404 with a message' do
        get :show, params: { id: uuid }

        expect(response.status).to eq(404)
        expect(response.body).to include("Couldn't find Opportunity")
      end
    end
  end
end
