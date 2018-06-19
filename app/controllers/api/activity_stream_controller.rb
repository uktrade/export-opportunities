require 'hawk'
require 'json'

module Api
  class ActivityStreamController < ApplicationController
    def respond_401(message)
      respond_to do |format|
        response.headers['Content-Type'] = 'application/json'
        error_object = {
          message: message,
        }
        format.json { render status: 401, json: error_object.to_json }
      end
    end

    def index
      # 401 if the server can't authenticate the request
      # 403 is never sent, since there is is no finer granularity for this endpoint:
      # the holder of the secret key is allowed to access the data

      # Ensure connecting from an authorized IP
      # request.remote_ip does look at X-Forwarded-For, and so is suitable behind a
      # load balancer
      authorized_ip_addresses = Figaro.env.ACTIVITY_STREAM_IP_WHITELIST.split(',')
      unless authorized_ip_addresses.include?(request.remote_ip)
        respond_401 'Connecting from unauthorized IP'
        return
      end

      # Ensure Authorization header is sent
      unless request.headers.key?('Authorization')
        respond_401 'Authorization header is missing'
        return
      end

      # Ensure Authorization header is correct
      check_and_save_nonce = proc do |nonce|
        redis = Redis.new(url: Figaro.env.redis_url)
        key = 'activity-stream-nonce-' + nonce
        key_used = redis.get(key)
        if key_used
          true
        else
          redis.set(key, true)
          redis.expire(key, 120)
          false
        end
      end
      credentials = {
        id: Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        key: Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        algorithm: 'sha256',
      }
      res = Hawk::Server.authenticate(
        request.headers['Authorization'],
        method: request.method,
        request_uri: request.original_fullpath,
        host: request.host,
        port: '443',
        content_type: request.headers['Content-Type'],
        payload: request.body.read,
        credentials_lookup: ->(id) { id == credentials[:id] ? credentials : nil },
        nonce_lookup: check_and_save_nonce
      )
      if res != credentials
        respond_401 res.message
        return
      end

      contents = {
        secret: 'content-for-pen-test',
      }
      respond_to do |format|
        response.headers['Content-Type'] = 'application/activity+json'
        format.json { render status: 200, json: contents.to_json }
      end
    end
  end
end
