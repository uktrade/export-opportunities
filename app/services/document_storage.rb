require 'aws-sdk'

class DocumentStorage
  def initialize
    @s3 = Aws::S3::Resource.new(
      region: Figaro.env.AWS_REGION_PTU!,
      credentials: Aws::Credentials.new(
        Figaro.env.AWS_ACCESS_KEY_ID!,
        Figaro.env.AWS_SECRET_ACCESS_KEY!
      )
    )
    @s3_client = Aws::S3::Client.new(
      region: Figaro.env.AWS_REGION_PTU!,
      credentials: Aws::Credentials.new(
        Figaro.env.AWS_ACCESS_KEY_ID!,
        Figaro.env.AWS_SECRET_ACCESS_KEY!
      )
    )
    @bucket_name = Figaro.env.post_user_communication_s3_bucket!
  end

  def call(filename, file_path)
    store_file(filename, file_path)
  end

  def store_file(filename, file_path)
    obj = @s3.bucket(@bucket_name).object(filename)
    obj.upload_file(file_path)
  end

  def put_object(body, key)
    @s3_client.put_object(body: body, bucket: @bucket_name, key: key)
  end

  def read_file(filename)
    @s3_client.get_object(bucket: @bucket_name, key: filename)
  rescue Aws::S3::Errors::NoSuchKey
    'error, specified file does not exist'
  end
end
