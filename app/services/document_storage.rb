require 'aws-sdk'

class DocumentStorage
  def initialize
    # we need our data to get stored in London, UK
    @s3 = Aws::S3::Resource.new(region: 'eu-west-2', credentials: Aws::Credentials.new(Figaro.env.aws_access_key_id!, Figaro.env.aws_secret_access_key!))
    @bucket_name = Figaro.env.post_user_communication_s3_bucket!
  end

  def call(filename, file)
    store_file(filename, file)
  end

  def store_file(filename, file)
    obj = @s3.bucket(@bucket_name).object(filename)
    obj.upload_file(file)
  end
end
