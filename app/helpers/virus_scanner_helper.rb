require 'rest-client'

module VirusScannerHelper
  def scan_clean?(file_path)
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
end