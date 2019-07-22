require 'rails_helper'
require 'spec_helper'

RSpec.describe SentenceCaseEnforcer, type: :service do

  before do
    Word.create(text: 'usa', uppercase: true)
    Word.create(text: 'france', capitalize: true)
  end

  describe '#call' do
    it "enforces sentence case in title" do
      #
      # Capitalise propert nouns and acronyms
      #
      params = opportunity_params(title: "EXCELLENT OPPORTUNITY. INVEST IN USA AND FRANCE TODAY")
      converted_params = SentenceCaseEnforcer.new(params).call
      expect(converted_params[:title]).to eq "Excellent opportunity. Invest in USA and France today"
    end
    it "enforces sentence case in teaser" do
      #
      # Leave punctuation as it was
      #
      params = opportunity_params(teaser: "ATTENTION ALL INVESTORS?? LOOKING FOR FAST ACTING 40% SALE")
      converted_params = SentenceCaseEnforcer.new(params).call
      expect(converted_params[:teaser]).to eq "Attention all investors?? Looking for fast acting 40% sale"
    end
    it "enforces sentence case in description" do
      params = opportunity_params(description: "DESCRIPTION: HERE")
      converted_params = SentenceCaseEnforcer.new(params).call
      expect(converted_params[:description]).to eq "Description: here"
    end
    it "ignore mixed case scenarios" do
      #
      # For mixed case descriptions, current approach is to leave as is to avoid any 
      # mistaken changes
      #
      params = opportunity_params(description:
        "WE HAVEN'T YET RECEIVED A DESCRIPTION of THE PROPERTY... still receiving data from usa")
      converted_params = SentenceCaseEnforcer.new(params).call
      expect(converted_params[:description]).to eq(
        "WE HAVEN'T YET RECEIVED A DESCRIPTION of THE PROPERTY... still receiving data from usa")
    end
  end

end