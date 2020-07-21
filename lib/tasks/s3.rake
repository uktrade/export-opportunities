require 'aws-sdk'

namespace :s3 do
  namespace :assets do
    desc 'Sync S3 assets from origin bucket to PaaS bucket'
    task :sync, %i[
      origin_aws_access_key_id origin_aws_secret_access_key
      origin_aws_region origin_bucket_name dry_run
    ] => [:environment] do |_t, args|
      s3_resource = Aws::S3::Resource.new(
        region: args[:origin_aws_region],
        credentials: Aws::Credentials.new(
          args[:origin_aws_access_key_id],
          args[:origin_aws_secret_access_key]
        )
      )
      s3_client_origin = Aws::S3::Client.new(
        region: args[:origin_aws_region],
        credentials: Aws::Credentials.new(
          args[:origin_aws_access_key_id],
          args[:origin_aws_secret_access_key]
        )
      )
      s3_client_target = DocumentStorage.new

      bucket = s3_resource.bucket(args[:origin_bucket_name])
      assets = bucket.objects

      Rails.logger.info "Starting to copy #{assets.count} assets:"
      assets.each do |asset|
        resp = s3_client_origin.get_object(bucket: bucket.name, key: asset.key)
        Rails.logger.info "Coping "\
          "#{document_url(args[:origin_aws_region], bucket.name, asset.key)} to "\
          "#{document_url(Figaro.env.aws_region, Figaro.env.post_user_communication_s3_bucket, asset.key)}"

        s3_client_target.put_object(resp.body.read, asset.key) if args[:dry_run]
      end
    end

    def document_url(region, bucket, obj_key)
      'https://s3.' + region + '.amazonaws.com/' + bucket + '/' + obj_key
    end
  end
end