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
        s3_link = document_url(
          Figaro.env.aws_region,
          Figaro.env.post_user_communication_s3_bucket,
          asset.key
        )
        resp = s3_client_origin.get_object(bucket: bucket.name, key: asset.key)
        Rails.logger.info "Coping "\
          "#{document_url(args[:origin_aws_region], bucket.name, asset.key)} to #{s3_link}"

        s3_client_target.put_object(resp.body.read, asset.key) unless args[:dry_run]
        DocumentUrlMapper.where("s3_link LIKE ?", "%#{asset.key}%").each do |dm|
          hashed_id = {
            old: dm.hashed_id,
            new: DocumentUrlShortener.new.hash_link(s3_link, dm.user_id, dm.enquiry_id)
          }
          s3_link = {
            old: dm.s3_link,
            new: s3_link
          }
          Rails.logger.info "old hashed_id: #{hashed_id[:old]}, new hashed_id: #{hashed_id[:new]}"
          Rails.logger.info "old s3_link: #{s3_link[:old]}, new s3_link: #{s3_link[:new]}"

          update_objects!(dm, hashed_id, s3_link) unless args[:dry_run]
        end
      end
    end

    def document_url(region, bucket, obj_key)
      'https://s3.' + region + '.amazonaws.com/' + bucket + '/' + obj_key
    end

    def update_objects!(document_url_mapper, hashed_id, s3_link)
      document_url_mapper.hashed_id = hashed_id[:new]
      document_url_mapper.s3_link   = s3_link[:new]
      document_url_mapper.update!

      enquiry_response = EnquiryResponse.find_by(enquiry_id: document_url_mapper.enquiry_id)
      if enquiry_response
        enquiry_response.documents.gsub(
          "\"hashed_id\":\"#{hashed_id[:old]}\"", "\"hashed_id\":\"#{hashed_id[:new]}\""
        )
        enquiry_response.documents.gsub(
          "\"s3_link\":\"#{s3_link[:old]}\"", "\"s3_link\":\"#{s3_link[:new]}\""
        )
        enquiry_response.update!
      end
    end
  end
end
