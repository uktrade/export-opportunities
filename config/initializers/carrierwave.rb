CarrierWave.configure do |config|
  config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     Figaro.env.AWS_S3_ID,
    aws_secret_access_key: Figaro.env.AWS_S3_SECRET,
    region:                Figaro.env.AWS_S3_REGION
  }
  config.fog_directory  = Figaro.env.AWS_S3_BUCKET
  config.fog_public     = false
  config.fog_attributes = { cache_control: "public, max-age=#{3.years.to_i}" }
end
