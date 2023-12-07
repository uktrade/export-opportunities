require 'rails_helper'

=begin
NOTE: These tests have been disabled as the OppsQualityConnector feature no longer works, and has been depreciated.
The original service that OppsQualityConnector called was https://api.cognitive.microsoft.com/bing/v7.0/SpellCheck.
This service has now been moved to https://api.bing.microsoft.com/v7.0/spellcheck. If this product is ever re-written
in future (likely in Python and as part of great-cms, then the TG_HOSTNAME Env var on Vault will need to be updated to
the new API endpoint: https://api.bing.microsoft.com/v7.0/spellcheck. A new API key will also have to be acquired,
and placed in the Env Var TG_API_KEY.

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
=end

