require 'rails_helper'

describe VirusScannerHelper do
  describe '#virus scanner' do
    it 'scan an infected file' do
      result = scan_clean?('spec/files/tender_sample_infected_file.txt')
      expect(result).to eq(false)
    end

    it 'scan a clean file' do
      result = scan_clean?('spec/files/tender_sample_file.txt')
      expect(result).to eq(true)
    end
  end
end
