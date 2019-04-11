require 'rails_helper'

RSpec.describe CategorisationMicroservice, type: :service do

  before do
    @cpv = 38511000.freeze
  end

  describe "#call" do

    it "returns array of results when given a cpv code" do
      first_result = CategorisationMicroservice.new(@cpv).call[0]
      expect(first_result["sector_id"]).to eq [10, 23, 24, 25, 7, 26, 27, 29]
      expect(first_result["hsid"]).to eq 8456
      expect(first_result["description"]).to eq "Machine-tools; for \
working any material by removal of material, by laser or other light \
or photon beam, ultrasonic, electro-discharge, electro-chemical, \
electron beam, ionic-beam, or plasma arc processes; water-jet cutting machines"
      expect(first_result["sectorname"]).to eq [
                                                  "Construction",
                                                  "Marine",
                                                  "Mechanical Electrical & Process Engineering",
                                                  "Metallurgical Process Plant",
                                                  "Chemicals",
                                                  "Metals, Minerals & Materials",
                                                  "Mining",
                                                  "Ports & Logistics"
                                               ]
      expect(first_result["cpvid"]).to eq "38511000"
    end
    it "returns error when no cpv code provided" do
      response = CategorisationMicroservice.new(nil).call
      expect(response).to eq "Error: CPV code not given"
    end
  end
  describe "#sector_ids" do
    it "returns a flattened array of ids" do
      sector_ids = CategorisationMicroservice.new(@cpv).sector_ids
      expect(sector_ids).to eq [10, 23, 24, 25, 7, 26, 27, 29]
    end

    it "returns an empty array of ids if service cant find the sector ids" do
      sector_ids = CategorisationMicroservice.new(34121110).sector_ids
      expect(sector_ids).to eq []
    end
  end
end