require 'rails_helper'

describe VirusScannerHelper do
  describe '#virus scanner with local file' do
    it 'scan an infected file' do
      result = scan_clean_by_file_path?('spec/files/tender_sample_infected_file.txt')
      expect(result).to eq(false)
    end

    it 'scan a clean file' do
      result = scan_clean_by_file_path?('spec/files/tender_sample_file.txt')
      expect(result).to eq(true)
    end
  end

  describe '#virus scanner with file stream' do
    it 'scan an infected file' do
      result = scan_clean?('test_infected_file', File.open('spec/files/tender_sample_infected_file.txt', 'rb'))
      expect(result).to eq(false)
    end

    it 'scan a clean file' do
      result = scan_clean?('test_clean_file', File.open('spec/files/tender_sample_file.txt', 'rb'))
      expect(result).to eq(true)
    end
  end
end
