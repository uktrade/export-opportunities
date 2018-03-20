require 'rails_helper'

# These tests require internet connection to the ClamAV DIT server

describe VirusScannerHelper do
  describe '#virus scanner with local file' do
    it 'scan an infected file' do
      result = scan_clean_by_file_path?('spec/files/tender_sample_infected_file.txt')
      expect(result['malware']).to eq(true)
      expect(result['reason']).to eq('Eicar-Test-Signature')
    end

    it 'scan a clean file' do
      result = scan_clean_by_file_path?('spec/files/tender_sample_file.txt')
      expect(result['malware']).to eq(false)
    end
  end

  describe '#virus scanner with file stream' do
    it 'scan an infected file' do
      result = scan_clean('test_infected_file', File.open('spec/files/tender_sample_infected_file.txt', 'rb'))
      expect(result['malware']).to eq(true)
    end

    it 'scan a clean file' do
      result = scan_clean('test_clean_file', File.open('spec/files/tender_sample_file.txt', 'rb'))
      expect(result['malware']).to eq(false)
    end

    it 'scan a clean zip file' do
      result = scan_clean('test_clean_file', File.open('spec/files/tender_sample_file.zip', 'rb'))
      expect(result['malware']).to eq(false)
    end

    it 'scan a clean zip pw protected file' do
      result = scan_clean('test_clean_file', File.open('spec/files/tender_sample_file_pw.zip', 'rb'))
      expect(result['malware']).to eq(true)
      expect(result['reason']).to eq('Heuristics.Encrypted.Zip')
    end
  end
end
