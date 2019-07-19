require 'rails_helper'
require 'spec_helper'

RSpec.describe SentenceCaseEnforcer, type: :service do

  before do
    Word.create(text: 'usa', uppercase: true)
    Word.create(text: 'france', capitalize: true)
  end

  describe '#call' do
    it "enforces sentence case in title, ignoring exceptions" do
      params = opportunity_params(title: "EXCELLENT OPPORTUNITY. INVEST IN USA AND FRANCE TODAY")
      converted_params = SentenceCaseEnforcer.new(params).call
      expect(converted_params[:title]).to eq "Excellent opportunity. Invest in USA and France today"
    end
    it "enforces sentence case in teaser, ignoring exceptions" do
      params = opportunity_params(teaser: "EXCELLENT OPPORTUNITY. INVEST IN USA AND FRANCE TODAY")
      converted_params = SentenceCaseEnforcer.new(params).call
      expect(converted_params[:teaser]).to eq "Excellent opportunity. Invest in USA and France today"
    end
    it "enforces sentence case in description, ignoring exceptions" do
      params = opportunity_params(description: "EXCELLENT OPPORTUNITY. INVEST IN USA AND FRANCE TODAY")
      converted_params = SentenceCaseEnforcer.new(params).call
      expect(converted_params[:description]).to eq "Excellent opportunity. Invest in USA and France today"
    end
  end

end