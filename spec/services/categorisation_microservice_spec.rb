require 'rails_helper'

RSpec.describe CategorisationMicroservice, type: :service do

  before do
    @cpv = 38511000.freeze
  end

  def url_for(cpv)
    "#{ENV['CATEGORISATION_URL']}/api/matchers/cpv/?cpv_id=#{cpv}&format=json"
  end

  describe "#call" do

    it "returns array of results when given a cpv code" do
      stub_request(:get, url_for(@cpv)).to_return(body: [{
        "sector_id"=>[5, 20],
        "hsid"=>9011,
        "description"=>"Microscopes, compound optical; including those for photomicrography, cinephotomicrography or microprojection",
        "sectorname"=>["Biotechnology & Pharmaceuticals", "Healthcare & Medical"],
        "cpvid"=>"38511000",
        "cpv_description"=>"Electron microscopes"
      }].to_json, status: 200)

      first_result = CategorisationMicroservice.new(@cpv).call[0]
      expect(first_result["sector_id"]).to eq [5, 20]
      expect(first_result["hsid"]).to eq 9011
      expect(first_result["description"]).to eq "Microscopes, compound optical;\
 including those for photomicrography, cinephotomicrography or microprojection"
      expect(first_result["sectorname"]).to eq [
                                                  "Biotechnology & Pharmaceuticals",
                                                  "Healthcare & Medical"
                                               ]
      expect(first_result["cpvid"]).to eq "38511000"
      expect(first_result["cpv_description"]).to eq "Electron microscopes"
    end
    it "returns error when no cpv code provided" do
      stub_request(:get, url_for(nil)).to_return(body: [].to_json, status: 200)
      response = CategorisationMicroservice.new(nil).call
      expect(response).to eq "Error: CPV code not given"
    end
  end
  describe "#sector_ids" do
    it "returns a flattened array of ids" do
      stub_request(:get, url_for(@cpv)).to_return(body: [{
        "sector_id"=>[5, 20],
        "hsid"=>9011,
        "description"=>"Microscopes, compound optical; including those for photomicrography, cinephotomicrography or microprojection",
        "sectorname"=>["Biotechnology & Pharmaceuticals", "Healthcare & Medical"],
        "cpvid"=>"38511000",
        "cpv_description"=>"Electron microscopes"
      }].to_json, status: 200)
      sector_ids = CategorisationMicroservice.new(@cpv).sector_ids
      expect(sector_ids).to eq [5, 20]
    end

    it "returns an empty array if service cant find the sector ids" do
      stub_request(:get, url_for(12313123)).to_return(body: [].to_json, status: 200)
      sector_ids = CategorisationMicroservice.new(34121110).sector_ids
      expect(sector_ids).to eq []
    end

    it "returns an empty array if the service responds with something unexpected" do
      stub_request(:get, url_for(@cpv)).to_return(status: 200, body: '{"Error": "Error"}' )
      sector_ids = CategorisationMicroservice.new(@cpv).sector_ids
      expect(sector_ids).to eq []
    end

    it "returns an empty array if the service responds with null" do
      stub_request(:get, url_for(@cpv)).to_return(status: 200, body: '[{"sector_id": null}]' )
      sector_ids = CategorisationMicroservice.new(@cpv).sector_ids
      expect(sector_ids).to eq []
    end
  end
end