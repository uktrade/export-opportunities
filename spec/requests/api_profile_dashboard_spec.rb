require 'rails_helper'

describe 'api users can fetch expopps opportunities and email alerts' do
  FORBIDDEN = { 'status' => 'Forbidden', 'code' => 403 }.freeze
  BAD_REQUEST = { 'status' => 'Bad Request', 'code' => 400 }.freeze

  before :each do
    allow(Figaro.env).to receive(:api_profile_dashboard_shared_secret).and_return('a_stubbed_secret')
    @secret = Figaro.env.api_profile_dashboard_shared_secret
  end

  it 'submit a valid request', skip: true do
    enquiry = create(:enquiry)
    create(:enquiry, user: enquiry.user)
    subscription = create(:subscription, user: enquiry.user)
    create(:subscription, user: enquiry.user)
    user = enquiry.user.uid

    get "/export-opportunities/api/profile_dashboard?hashed_sso_id=#{user}&shared_secret=#{@secret}"

    expect(response.status).to eql(200)
    parsed_body = JSON.parse(response.body)
    expect(parsed_body.to_s).to include subscription.search_term
    expect(parsed_body.to_s).to include enquiry.opportunity.title
    expect(parsed_body['email_alerts']).to be_kind_of(Array)
    expect(parsed_body['email_alerts'].first).to be_kind_of(Hash)
    expect(parsed_body['enquiries']).to be_kind_of(Array)
    expect(parsed_body['enquiries'].first).to be_kind_of(Hash)
  end

  it 'submit an invalid user id' do
    enquiry = create(:enquiry)
    create(:enquiry, user: enquiry.user)
    create(:subscription, user: enquiry.user)
    create(:subscription, user: enquiry.user)
    user = 'invalid_user'

    get "/export-opportunities/api/profile_dashboard?hashed_sso_id=#{user}&shared_secret=#{@secret}"

    expect(response.status).to eql(403)
    expect(JSON.parse(response.body)).to include FORBIDDEN
  end

  it 'submit invalid shared secret' do
    enquiry = create(:enquiry)
    create(:enquiry, user: enquiry.user)
    user = enquiry.user.uid

    get "/export-opportunities/api/profile_dashboard?hashed_sso_id=#{user}&shared_secret=not_so_secret"

    expect(response.status).to eql(403)
    expect(JSON.parse(response.body)).to include FORBIDDEN
  end

  it 'lacks shared_secret parameter from request' do
    user = '-999'

    get "/export-opportunities/api/profile_dashboard?hashed_sso_id=#{user}"

    expect(response.status).to eql(400)
    expect(JSON.parse(response.body)).to include BAD_REQUEST
  end

  it 'lacks hashed_sso_id parameter from request' do
    get "/export-opportunities/api/profile_dashboard?shared_secret=#{@secret}"

    expect(response.status).to eql(400)
    expect(JSON.parse(response.body)).to include BAD_REQUEST
  end
end
