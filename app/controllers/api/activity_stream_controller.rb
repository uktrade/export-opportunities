require 'base64'
require 'digest'
require 'json'
require 'openssl'

module Api
  class ActivityStreamController < ApplicationController
    def authenticate(request)
      return [false, 'Connecting from unauthorized IP'] unless request.headers.key?('X-Forwarded-For')
      remote_ips = request.headers['X-Forwarded-For'].split(',')
      return [false, 'Connecting from unauthorized IP'] unless remote_ips.length >= 2
      authorized_ip_addresses = Figaro.env.ACTIVITY_STREAM_IP_WHITELIST.split(',')
      return [false, 'Connecting from unauthorized IP'] unless authorized_ip_addresses.include?(remote_ips[-2])

      return [false, 'Authorization header is missing'] unless request.headers.key?('Authorization')

      parsed_header_array = request.headers['Authorization'].scan(/([a-z]+)="([^"]+)"/)
      parsed_header = parsed_header_array.each_with_object({}) do |key_val, memo|
        memo[key_val[0].to_sym] = key_val[1]
      end

      return [false, 'Invalid header']  unless /^Hawk (((?<="), )?[a-z]+="[^"]*")*$/.match?(request.headers['Authorization'])
      return [false, 'Missing ts']      unless parsed_header.key? :ts
      return [false, 'Invalid ts']      unless /\d+/.match?(parsed_header[:ts])
      return [false, 'Missing hash']    unless parsed_header.key? :hash
      return [false, 'Missing mac']     unless parsed_header.key? :mac
      return [false, 'Missing nonce']   unless parsed_header.key? :nonce
      return [false, 'Missing id']      unless parsed_header.key? :id
      return [false, 'Unidentified id'] unless secure_compare(correct_credentials[:id], parsed_header[:id])

      canonical_payload = 'hawk.1.payload'                     + "\n" +
                          request.headers['Content-Type'].to_s + "\n" +
                          request.body.read.to_s               + "\n"
      correct_payload_hash = Digest::SHA256.base64digest canonical_payload

      canonical_request = 'hawk.1.header'           + "\n" +
                          parsed_header[:ts]        + "\n" +
                          parsed_header[:nonce]     + "\n" +
                          request.method            + "\n" +
                          request.original_fullpath + "\n" +
                          request.host              + "\n" \
                          '443'                     + "\n" +
                          correct_payload_hash      + "\n" + "\n"
      correct_mac = Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest.new('sha256'), correct_credentials[:key], canonical_request
        )
      ).strip
      return [false, 'Invalid hash']  unless secure_compare(correct_payload_hash, parsed_header[:hash])
      return [false, 'Stale ts']      unless (Time.now.getutc.to_i - parsed_header[:ts].to_i).abs <= 60
      return [false, 'Invalid mac']   unless secure_compare(correct_mac, parsed_header[:mac])
      return [false, 'Invalid nonce'] unless nonce_available?(parsed_header[:nonce], parsed_header[:id])

      [true, '']
    end

    def secure_compare(a, b)
      ActiveSupport::SecurityUtils.secure_compare(a, b)
    end

    def nonce_available?(nonce, id)
      redis = Redis.new(url: Figaro.env.redis_url)
      key = "activity-stream-nonce-#{nonce}-#{id}"
      key_set = redis.setnx(key, true)
      redis.expire(key, 120) if key_set
      key_set
    end

    def correct_credentials
      {
        id: Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        key: Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        algorithm: 'sha256',
      }
    end

    def respond_401(message)
      respond_to do |format|
        response.headers['Content-Type'] = 'application/json'
        error_object = {
          message: message,
        }
        format.json { render status: 401, json: error_object.to_json }
      end
    end

    def respond_200(contents)
      respond_to do |format|
        response.headers['Content-Type'] = 'application/activity+json'
        format.json { render status: 200, json: contents.to_json }
      end
    end

    def index
      # 401 if the server can't authenticate the request
      # 403 is never sent, since there is is no finer granularity for this endpoint:
      # the holder of the secret key is allowed to access the data

      is_authentic, message = authenticate(request)
      return respond_401 message unless is_authentic

      respond_200 secret: 'content-for-pen-test'
    end
  end
end
