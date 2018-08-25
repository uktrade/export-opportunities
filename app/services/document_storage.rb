require 'aws-sdk'

class DocumentStorage
  def initialize
    # we need our data to be stored in London, UK
    @s3 = Aws::S3::Resource.new(region: ENV.fetch('aws_region_ptu'), credentials: Aws::Credentials.new(ENV.fetch('AWS_ACCESS_KEY_ID'), ENV.fetch('AWS_SECRET_ACCESS_KEY')))
    @s3_client = Aws::S3::Client.new(region: ENV.fetch('aws_region_ptu'), credentials: Aws::Credentials.new(ENV.fetch('AWS_ACCESS_KEY_ID'), ENV.fetch('AWS_SECRET_ACCESS_KEY')))
    @bucket_name = ENV.fetch('post_user_communication_s3_bucket')
  end

  def call(filename, file_path)
    store_file(filename, file_path)
  end

  def store_file(filename, file_path)
    obj = @s3.bucket(@bucket_name).object(filename)
    obj.upload_file(file_path)
  end

  def read_file(filename)
    @s3_client.get_object(bucket: @bucket_name, key: filename)
  rescue Aws::S3::Errors::NoSuchKey
    return 'error, specified file does not exist'
  end
end
