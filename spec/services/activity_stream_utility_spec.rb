RSpec.describe ActivityStreamUtility, type: :service do

  it "Authenticates and provides a response" do
    skip("Only valid if localhost is running")
    request = ActivityStreamUtility.new.request('localhost:3001/api/activity_stream/opportunities')
    parsed_request = JSON.parse(request)
    expect(parsed_request).to have_key("@context")
  end

end