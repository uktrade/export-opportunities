require 'base64'
require 'digest'
require 'json'
require 'openssl'

module Api
  class ActivityStreamController < ApplicationController
    def authenticate(
      authorization_header:,
      method:, request_uri:, host:, port:,
      content_type:, payload:
    )
      parsed_header_array = authorization_header.scan(/([a-z]+)="([^"]+)"/)
      parsed_header = parsed_header_array.each_with_object({}) do |key_val, memo|
        memo[key_val[0].to_sym] = key_val[1]
      end

      return { message: 'Invalid header' }  unless /^Hawk (((?<="), )?[a-z]+="[^"]*")*$/.match?(authorization_header)
      return { message: 'Missing ts' }      unless parsed_header.key? :ts
      return { message: 'Invalid ts' }      unless /\d+/.match?(parsed_header[:ts])
      return { message: 'Missing hash' }    unless parsed_header.key? :hash
      return { message: 'Missing mac' }     unless parsed_header.key? :mac
      return { message: 'Missing nonce' }   unless parsed_header.key? :nonce
      return { message: 'Missing id' }      unless parsed_header.key? :id
      return { message: 'Unidentified id' } unless secure_compare(correct_credentials[:id], parsed_header[:id])

      canonical_payload = 'hawk.1.payload'  + "\n" +
                          content_type.to_s + "\n" +
                          payload.to_s      + "\n"
      correct_payload_hash = Digest::SHA256.base64digest canonical_payload

      canonical_request = 'hawk.1.header'       + "\n" +
                          parsed_header[:ts]    + "\n" +
                          parsed_header[:nonce] + "\n" +
                          method                + "\n" +
                          request_uri           + "\n" +
                          host                  + "\n" +
                          port                  + "\n" +
                          correct_payload_hash  + "\n" + "\n"
      correct_mac = Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest.new('sha256'), correct_credentials[:key], canonical_request
        )
      ).strip
      return { message: 'Invalid hash' }  unless secure_compare(correct_payload_hash, parsed_header[:hash])
      return { message: 'Stale ts' }      unless (Time.now.getutc.to_i - parsed_header[:ts].to_i).abs <= 60
      return { message: 'Invalid mac' }   unless secure_compare(correct_mac, parsed_header[:mac])
      return { message: 'Invalid nonce' } unless nonce_available?(parsed_header[:nonce], parsed_header[:id])

      correct_credentials
    end

    def secure_compare(a, b)
      ActiveSupport::SecurityUtils.variable_size_secure_compare(a, b)
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

    def is_authorized_ip_address(request)
      # Ensure connecting from an authorized IP: the second-to-last IP in
      # X-Fowarded-For isn't spoofable in PaaS

      return false unless request.headers.key?('X-Forwarded-For')

      remote_ips = request.headers['X-Forwarded-For'].split(',')
      authorized_ip_addresses = Figaro.env.ACTIVITY_STREAM_IP_WHITELIST.split(',')
      return remote_ips.length >= 2 && authorized_ip_addresses.include?(remote_ips[-2])
    end

    def index
      # 401 if the server can't authenticate the request
      # 403 is never sent, since there is is no finer granularity for this endpoint:
      # the holder of the secret key is allowed to access the data

      unless is_authorized_ip_address(request)
        respond_401 'Connecting from unauthorized IP'
        return 
      end

      # Ensure Authorization header is sent
      unless request.headers.key?('Authorization')
        respond_401 'Authorization header is missing'
        return
      end

      # Ensure Authorization header is correct
      res = authenticate(
        authorization_header: request.headers['Authorization'],
        method: request.method,
        request_uri: request.original_fullpath,
        host: request.host,
        port: '443',
        content_type: request.headers['Content-Type'],
        payload: request.body.read
      )
      if res != correct_credentials
        respond_401 res[:message]
        return
      end

      respond_200 secret: 'content-for-pen-test'
    end
  end
end
