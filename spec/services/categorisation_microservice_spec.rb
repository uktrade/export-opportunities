require 'rails_helper'

RSpec.describe CategorisationMicroservice, type: :service do

  before do
    @cpv = 38511000.freeze
  end

  describe "#call" do

    it "returns array of results when given a cpv code" do
      first_result = CategorisationMicroservice.new(@cpv).call[0]
      expect(first_result["sector_id"]).to eq [5, 20]
      expect(first_result["hsid"]).to eq 9012
      expect(first_result["description"]).to eq "Microscopes (excluding optical microscopes); diffraction apparatus"
      expect(first_result["sectorname"]).to eq [
                                                  "Biotechnology & Pharmaceuticals",
                                                  "Healthcare & Medical"
                                               ]
      expect(first_result["cpvid"]).to eq "38511000"
    end
    it "returns error when cpv code provided" do
      response = CategorisationMicroservice.new(nil).call
      expect(response).to eq "Error: CPV code not given"
    end
  end
  describe "#sector_ids" do
    it "returns a flattened array of ids" do
      sector_ids = CategorisationMicroservice.new(@cpv).sector_ids
      expect(sector_ids).to eq [5, 20]
    end
  end

end