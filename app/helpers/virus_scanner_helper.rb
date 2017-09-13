require 'rest-client'

module VirusScannerHelper
  def scan_clean_by_file_path?(file_path)
    request = RestClient::Request.new(
      method: :post,
      url: Figaro.env.CLAM_AV_HOST,
      payload: {
        multipart: true,
        file: File.new(file_path, 'rb'),
      },
      user: Figaro.env.CLAM_AV_USERNAME,
      password: Figaro.env.CLAM_AV_PASSWORD
    )

    response = request.execute

    response.body.eql?('OK') ? true : false
  end

  def scan_clean?(filename, file_blob)
    File.open(filename, 'wb') do |f|
      f.write file_blob.read
    end
    scan_clean_by_file_path?(filename)
  end
end
