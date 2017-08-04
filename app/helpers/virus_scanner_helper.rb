require 'rest-client'

module VirusScannerHelper
  def scan_clean_by_file_path?(file_path)
    request = RestClient::Request.new(
<<<<<<< HEAD
<<<<<<< HEAD
        method: :post,
        url: Figaro.env.CLAM_AV_HOST,
        payload: {
            multipart: true,
            file: File.new(file_path, 'rb'),
        },
        user: Figaro.env.CLAM_AV_USERNAME,
        password: Figaro.env.CLAM_AV_PASSWORD
=======
=======
>>>>>>> 3d9e728... (fix) multiple attachments, using carrierwave
      method: :post,
      url: Figaro.env.CLAM_AV_HOST,
      payload: {
        multipart: true,
        file: File.new(file_path, 'rb'),
      },
      user: Figaro.env.CLAM_AV_USERNAME,
      password: Figaro.env.CLAM_AV_PASSWORD
<<<<<<< HEAD
>>>>>>> b466330... (fix) multiple attachments, using carrierwave
=======
>>>>>>> 3d9e728... (fix) multiple attachments, using carrierwave
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
