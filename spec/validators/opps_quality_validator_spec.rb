require 'rails_helper'

RSpec.describe OppsQualityValidator do
  describe '#validate_each or #call' do

    it "Retrieves a fresh opportunity score" do
      opportunity = create(:opportunity, title: "A perfect title")
      expect(OppsQualityValidator.new.call(opportunity)).to eq 100
    end

    it "Retrieves an existing quality score" do
      opportunity = create(:opportunity, title: "A perfect title")
      OppsQualityValidator.new.call(opportunity)

      expect(opportunity.opportunity_checks.count).to eq 1
      # > 80 as the quality validator is unreliable
      expect(OppsQualityValidator.new.call(opportunity)).to be > 80
      expect(opportunity.opportunity_checks.count).to eq 1
    end

    it "Returns 0 if the API fails when creating a new quality score" do
      cached_TG_API_KEY = ENV["TG_API_KEY"]
      ENV["TG_API_KEY"] = "broken"
      
      opportunity = create(:opportunity)
      expect(OppsQualityValidator.new.call(opportunity)).to eq 0

      ENV["TG_API_KEY"] = cached_TG_API_KEY
    end

  end
end


