require 'rails_helper'

RSpec.describe VolumeOppsValidator do
  describe '#validate_each' do
    before(:each) do
      create(:country, name: 'New Zealand')
      opp = create(:opportunity)

      response_opps = JSON.parse(File.read('spec/files/volume_opps/response_hash.json'), quirks_mode: true)
      json_response_opps = JSON.parse(response_opps).with_indifferent_access

      @opportunity_params = VolumeOppsRetriever.new.opportunity_params(json_response_opps[:data].first)

    end

    it 'returns false for empty opportunity description' do
      @opportunity_params[:description] = nil
      result = VolumeOppsValidator.new.validate_each(@opportunity_params)
      expect(result).to eq false
    end

    it 'substitutes opportunity title with first 80 chars of description if nil' do
      @opportunity_params[:title] = nil
      @opportunity_params[:description] = 'Find and apply for overseas opportunities from businesses looking for products or services like yours'
      result = VolumeOppsValidator.new.validate_each(@opportunity_params)
      expect(@opportunity_params[:title]).to eq 'Find and apply for overseas opportunities from businesses looking for products o'
      expect(result).to eq true
    end

    it 'returns false if opportunity doesnt have a published date' do
      @opportunity_params[:first_published_at] = nil
      result = VolumeOppsValidator.new.validate_each(@opportunity_params)
      expect(result).to eq false
    end

    it 'returns false if opportunitys language is not english' do
      @opportunity_params[:language] = 'gr'
      result = VolumeOppsValidator.new.validate_each(@opportunity_params)
      expect(result).to eq false
    end

    it 'returns false if opportunity doesnt have an expiry date' do
      @opportunity_params[:response_due_on] = nil
      result = VolumeOppsValidator.new.validate_each(@opportunity_params)
      expect(result).to eq false
    end

    it 'returns false if opportunity doesnt belong to a country' do
      @opportunity_params[:country_ids] = nil
      result = VolumeOppsValidator.new.validate_each(@opportunity_params)
      expect(result).to eq false
    end

    it 'returns false if opportunity doesnt have buyers details(either name or address at least)' do
      @opportunity_params[:buyer_name] = nil
      @opportunity_params[:buyer_address] = nil
      result = VolumeOppsValidator.new.validate_each(@opportunity_params)
      expect(result).to eq false
    end

    it 'substitutes contact points details with default values if they dont exist' do
      first_contact = @opportunity_params[:contacts_attributes][0]
      first_contact[:name] = nil
      first_contact[:email] = nil
      result = VolumeOppsValidator.new.validate_each(@opportunity_params)
      expect(@opportunity_params[:contacts_attributes][0][:name]).to eq 'Export Opportunities Team'
      expect(@opportunity_params[:contacts_attributes][0][:email]).to eq 'exportopportunities@trade.gsi.gov.uk'
      expect(result).to eq true
    end

    it 'returns true for a valid opportunity' do
      result = VolumeOppsValidator.new.validate_each(@opportunity_params)
      expect(result).to eq true
    end
  end
end
