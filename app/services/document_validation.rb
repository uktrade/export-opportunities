class DocumentValidation
  include VirusScannerHelper

  def call(params, file)
    validate_params(params)

    clamav_scan(params['original_filename'], file)
  end

  def validate_params(params)
    raise Exception.new('no user id found') unless params['user_id']
    raise Exception.new('no enquiry id found') unless params['enquiry_id']
    raise Exception.new('no original filename found') unless params['original_filename']
  end

  def clamav_scan(filename, file_blob)
    begin
      raise Exception.new('VIRUS found') unless scan_clean?(filename, file_blob)
    rescue SocketError => e
      Rails.logger.error 'cant reach server'
      raise Exception.new('Cant reach server')
    end
  end
end