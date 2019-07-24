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
      response = CategorisationMicroservice.new(nil).call
      expect(response).to eq "Error: CPV code not given"
    end
  end
  describe "#sector_ids" do
    it "returns a flattened array of ids" do
      sector_ids = CategorisationMicroservice.new(@cpv).sector_ids
      expect(sector_ids).to eq [5, 20]
    end

    it "returns an empty array if service cant find the sector ids" do
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