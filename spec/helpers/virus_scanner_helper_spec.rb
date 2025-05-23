require 'rails_helper'

# These tests require internet connection to the ClamAV DIT server

describe VirusScannerHelper do
  describe '#virus scanner with local file' do
    it 'scan an infected file' do
      result = scan_clean_by_file_path?('spec/files/tender_sample_infected_file.txt')
      expect(result).to eq('NOTOK')
    end

    it 'scan a clean file' do
      skip('fixed in develop')
      result = scan_clean_by_file_path?('spec/files/tender_sample_file.txt')
      expect(result).to eq('OK')
    end
  end

  describe '#virus scanner with file stream' do
    it 'scan an infected file' do
      result = scan_clean('test_infected_file', File.open('spec/files/tender_sample_infected_file.txt', 'rb'))
      expect(result).to eq('NOTOK')
    end

    it 'scan a clean file' do
      result = scan_clean('test_clean_file', File.open('spec/files/tender_sample_file.txt', 'rb'))
      expect(result).to eq('OK')
    end

    it 'scan a clean zip file' do
      result = scan_clean('test_clean_file', File.open('spec/files/tender_sample_file.zip', 'rb'))
      expect(result).to eq('OK')
    end

    it 'scan a clean zip pw protected file' do
      # Password protected should return "has a virus"
      result = scan_clean('test_clean_file', File.open('spec/files/tender_sample_file_pw.zip', 'rb'))
      expect(result).to eq('NOTOK')
    end
  end
end
