require 'rails_helper'

RSpec.describe CmsLinksHelper do
  describe '#cms_url_for' do
    it 'prefixes the path with the CMS_BASE_URI' do
      allow(Figaro.env).to receive(:cms_base_uri).and_return('https://example.com/')

      result = cms_url_for('opportunities')
      expect(result).to eq('https://example.com/opportunities')
    end

    it 'returns the path, if CMS_BASE_URI is not set' do
      allow(Figaro.env).to receive(:cms_base_uri).and_return(nil)

      result = cms_url_for('opportunities')
      expect(result).to eq('/opportunities')
    end

    it 'prevents duplicate forward slashes after the domain' do
      allow(Figaro.env).to receive(:cms_base_uri).and_return('https://example.com/')

      result = cms_url_for('/opportunities')
      expect(result).to eq('https://example.com/opportunities')
    end
  end
end
