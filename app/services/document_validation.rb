class DocumentValidation
  include VirusScannerHelper

  def call(params, file)
    validate_params(params)

    clamav_scan(params['original_filename'], file)
  end

  def validate_params(params)
    unless params['user_id']
      @result = {
        errors: {
          type: 'missing parameter',
          message: 'no user id',
        },
      } end
    unless params['enquiry_id']
      @result = {
        errors: {
          type: 'missing parameter',
          message: 'no enquiry id found',
        },
      } end
    unless params['original_filename']
      @result = {
        errors: {
          type: 'missing parameter',
          message: 'no original filename found',
        },
      } end
  end

  def clamav_scan(filename, file_blob)
    unless scan_clean?(filename, file_blob)
      @result = {
        errors: {
          type: 'virus found',
          message: 'file is not clean',
        },
    } end
  rescue SocketError => e
    Rails.logger.error 'cant reach server', e
    raise Exception, 'Cant reach server'
  end
end
