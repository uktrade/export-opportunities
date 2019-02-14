require 'rails_helper'

# These tests require internet connection to the S3 bucket

RSpec.describe DocumentStorage do
  it 'stores a file into S3', focus: true do
    skip("Cannot connect from local environments into London Paas")
    # Create the document
    random_string = (0...8).map { (65 + rand(26)).chr }.join
    path = 'spec/files/tender_sample_file.txt'
    filename = 'test_filename'
    File.open(path, 'w'){ |file| file.write(random_string) }

    # Store the document
    DocumentStorage.new.store_file(filename, path)

    # Get the document
    response = DocumentStorage.new.read_file(filename)
    expect(response.body.read).to eq(random_string)
  end
end
