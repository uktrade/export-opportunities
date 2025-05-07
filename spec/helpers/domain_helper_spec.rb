# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DomainHelper do
  describe '#fetch_domain' do
    it 'returns business.gov.uk if the DOMAIN and BGS_SITE are the same' do
      allow(Figaro.env).to receive(:DOMAIN).and_return('business.gov.uk')
      allow(Figaro.env).to receive(:BGS_SITE).and_return('business.gov.uk')

      expect(fetch_domain).to eq('business.gov.uk')
    end

    it 'returns great.gov.uk if the DOMAIN and BGS_SITE are NOT the same' do
      allow(Figaro.env).to receive(:DOMAIN).and_return('great.gov.co.uk')
      allow(Figaro.env).to receive(:BGS_SITE).and_return('business.gov.uk')

      expect(fetch_domain).to eq('great.gov.uk')
    end

    it 'returns Business if the DOMAIN and BGS_SITE are the same and title_only is true' do
      allow(Figaro.env).to receive(:DOMAIN).and_return('business.gov.uk')
      allow(Figaro.env).to receive(:BGS_SITE).and_return('business.gov.uk')

      expect(fetch_domain(title_only: true)).to eq('Business')
    end

    it 'returns Great if the DOMAIN and BGS_SITE are NOT the same and title_only is true' do
      allow(Figaro.env).to receive(:DOMAIN).and_return('great.gov.co.uk')
      allow(Figaro.env).to receive(:BGS_SITE).and_return('business.gov.uk')

      expect(fetch_domain(title_only: true)).to eq('Great')
    end

    it 'returns hotfix domain if DOMAIN is www.hotfix.bgs.uktrade.digital' do
      allow(Figaro.env).to receive(:DOMAIN).and_return('www.hotfix.bgs.uktrade.digital')
      allow(Figaro.env).to receive(:BGS_SITE).and_return('www.hotfix.bgs.uktrade.digital')

      expect(fetch_domain).to eq('hotfix.bgs.uktrade.digital')
    end
  end
end
