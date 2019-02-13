require 'base64'
require 'digest'
require 'yajl'
require 'openssl'

MAX_PER_PAGE = 500

module Api
  class ActivityStreamController < ApplicationController
    def index
      redirect_to(action: :enquiries, params: params)
    end

    def enquiries
      check_auth && return

      search_after = params.fetch(:search_after, '0.000000_0')
      search_after_time_str, search_after_id_str = search_after.split('_')
      search_after_time = Float(search_after_time_str)
      search_after_id = Integer(search_after_id_str)

      companies_with_number = Enquiry
        .joins(opportunity: :service_provider)
        .joins(:user)
        .select(
          'enquiries.id, enquiries.created_at, enquiries.company_house_number, enquiries.existing_exporter, ' \
          'enquiries.company_sector, enquiries.company_name, enquiries.company_postcode, enquiries.company_url, ' \
          'enquiries.company_telephone, enquiries.first_name, enquiries.last_name, ' \
          'enquiries.opportunity_id, opportunities.title as opportunity_title, ' \
          'service_providers.name as opportunity_service_provider_name, ' \
          'users.email as user_email' \
        )
        .where("enquiries.company_house_number IS NOT NULL AND enquiries.company_house_number != ''")
        .where('enquiries.created_at > to_timestamp(?) OR (enquiries.created_at = to_timestamp(?) AND enquiries.id > ?)',
          search_after_time, search_after_time, search_after_id)
        .order('enquiries.created_at ASC, enquiries.id ASC')
      enquiries = companies_with_number.take(MAX_PER_PAGE)

      opportunity_ids = enquiries.map(&:opportunity_id)
      country_names = get_country_names(opportunity_ids)
      service_provider_names = get_service_provider_names(opportunity_ids)
      items = enquiries.map { |enquiry| enquiry_to_activity(country_names, service_provider_names, enquiry) }

      contents = to_activity_collection(items).merge(
        if enquiries.empty?
          {}
        else
          { next: "#{request.base_url}#{request.env['PATH_INFO']}?search_after=#{to_search_after(enquiries[-1], :created_at)}" }
        end
      )
      respond_200 contents
    end

    def opportunities
      check_auth && return

      search_after = params.fetch(:search_after, '0.000000_00000000-0000-4000-0000-000000000000')
      search_after_time_str, search_after_id_str = search_after.split('_')
      search_after_time = Float(search_after_time_str)
      search_after_id = String(search_after_id_str)

      opportunities = Opportunity.published.applicable
        .where('updated_at > to_timestamp(?) OR (updated_at = to_timestamp(?) AND id > ?::uuid)',
          search_after_time, search_after_time, search_after_id)
        .order('updated_at ASC, id ASC')
        .take(MAX_PER_PAGE)

      opportunity_ids = opportunities.map(&:id)
      country_names = get_country_names(opportunity_ids)
      service_provider_names = get_service_provider_names(opportunity_ids)
      items = opportunities.map { |opportunity| opportunity_to_activity(country_names, service_provider_names, opportunity) }
      contents = to_activity_collection(items).merge(
        if opportunities.empty?
          {}
        else
          { next: "#{request.base_url}#{request.env['PATH_INFO']}?search_after=#{to_search_after(opportunities[-1], :updated_at)}" }
        end
      )
      respond_200 contents
    end

    private

      def check_auth
        # 401 if the server can't authenticate the request
        # 403 is only sent if the activity stream is disabled, since there is
        # no finer granularity for this endpoint: the holder of the secret key
        # is allowed to access the data

        return respond(403, 'Activity Stream is disabled') unless ExportOpportunities.flipper.enabled?(:activity_stream)

        is_authentic, message = authenticate(request)
        return respond(401, message) unless is_authentic
      end

      def to_activity_collection(activities)
        {
          '@context': [
            'https://www.w3.org/ns/activitystreams', {
              'dit': 'https://www.trade.gov.uk/ns/activitystreams/v1',
            }
          ],
          'type': 'Collection',
          'orderedItems': activities,
        }
      end

      def enquiry_to_activity(country_names, service_provider_names, enquiry)
        # When making changes, be mindful to use .joins, .includes,
        # .preload or .eager_load in the query that has produced
        # `enquiry` in order to avoid any queries per activity.
        # If in doubt, while developing use
        #
        # ActiveRecord::Base.logger = Logger.new(STDOUT)
        obj_id = 'dit:exportOpportunities:Enquiry:' + enquiry.id.to_s
        activity_id = obj_id + ':Create'
        {
          'id': activity_id,
          'type': 'Create',
          'published': enquiry.created_at.to_datetime.rfc3339,
          'generator': {
            'type': 'Application',
            'name': 'dit:exportOpportunities',
          },
          'actor': [{
            'type': ['Organization', 'dit:Company'],
            'dit:companiesHouseNumber': enquiry.company_house_number,
            'dit:companyIsExistingExporter': enquiry.existing_exporter,
            'dit:sector': enquiry.company_sector,
            'dit:phoneNumber': enquiry.company_telephone,
            'name': enquiry.company_name,
            'location': {
              'dit:postcode': enquiry.company_postcode,
            },
            'url': enquiry.company_url,
          }, {
            'type': 'Person',
            'name': [enquiry.first_name, enquiry.last_name],
            'dit:emailAddress': enquiry.user_email,
          }],
          'object': {
            'type': ['Document', 'dit:exportOpportunities:Enquiry'],
            'id': obj_id,
            'published': enquiry.created_at.to_datetime.rfc3339,
            'url': admin_enquiry_url(enquiry),
            'inReplyTo': opportunity_object(country_names, service_provider_names, enquiry.opportunity),
          },
        }
      end

      # Creates a hash of data for an Opportunity
      def opportunity_to_activity(country_names, service_provider_names, opportunity)
        obj_id = 'dit:exportOpportunities:Opportunity:' + opportunity.id.to_s
        activity_id = obj_id + ':Create'
        {
          'id': activity_id, # Unique Id
          'type': 'Create',
          'published': opportunity.created_at.to_datetime.rfc3339,
          'object': opportunity_object(country_names, service_provider_names, opportunity),
        }
      end

      def opportunity_object(country_names, service_provider_names, opportunity)
        obj_id = 'dit:exportOpportunities:Opportunity:' + opportunity.id.to_s
        {
          'type': ['Document', 'dit:exportOpportunities:Opportunity'],
          # The following is used by Enquiry stream, may be deprecated soon - 11 Feb 2019
          'dit:exportOpportunities:Opportunity:id': opportunity.id.to_s,
          'id': obj_id,
          'name': opportunity.title,
          'url': opportunity_url(opportunity),
          'endTime': opportunity.response_due_on.to_datetime.rfc3339,
          'summary': opportunity.teaser,
          'content': opportunity.description,
          'dit:country': country_names[opportunity.id],
          'generator': {
            'type': ['Organization', 'dit:ServiceProvider'],
            'name': service_provider_names[opportunity.id],
          },
        }
      end

      # Returns a hash of country names with ids of opportunities beside
      #
      # Notes:
      # To avoid...
      # - A query per activity
      # - select * (as opposed to specifying column names)
      # - unnecessary joins
      # ... there doesn't seem to be a pure ActiveRecord way of doing this. Specifically, it
      # seems to be due to the fact that the countries of an opportunity is quite a "deep"
      # relation.
      # Note the WHERE IN (...) as opposted to WHERE IN (VALUES ...). The VALUES version was
      # tested on staging with 1000 IDs, and was found to be slower, and from EXPLAIN ANALYZE
      # it involved a full table scan, while the current version was faster and did not
      # involve a full table scan (other than on the countries table itself, but it's small
      # so that makes sense)
      #
      # Also, wake sure to not error with cases where both there are no opportunity IDs,
      # and if the opportunity has no associated countries.
      def get_country_names(opportunity_ids)
        opportunity_ids = opportunity_ids.map { |id| [nil, id] }
        where_clause = opportunity_ids.map.with_index { |_, i| "$#{i + 1}::uuid" }.join(',')

        country_names_str = \
          if opportunity_ids.empty? then {} else ActiveRecord::Base
            .connection
            .select_rows(
              'SELECT countries_opportunities.opportunity_id, STRING_AGG(countries.name, \'__SEP__\' ORDER BY name) as country_name ' \
              'FROM countries_opportunities ' \
              'INNER JOIN countries ON (countries_opportunities.country_id = countries.id) ' \
              'WHERE countries_opportunities.opportunity_id IN (' + where_clause + ') ' \
              'GROUP BY countries_opportunities.opportunity_id ',
              nil, opportunity_ids
            )
            .to_h
          end
        country_names_empty_str = Hash[opportunity_ids.map { |id, _| [id, ''] }]
        country_names_all = country_names_empty_str.merge(country_names_str)
        Hash[country_names_all.map { |opp_id, country_str| [opp_id, country_str.split('__SEP__')] }]
      end


      def get_service_provider_names(opportunity_ids)
        # Create a hash connecting service providers to their names. Hash is of format:
        # {
        #   "1": "British Embassy",
        #   "3": "British Consulate"
        # }
        provider_ids = Opportunity.where(id: opportunity_ids).map(&:service_provider_id)
        provider_names = Hash[
          ServiceProvider.where(id: provider_ids).map{|sp| [sp.id, sp.name] }
        ]
        # Perform a search connecting opportunities to the appropriate service provider name. Hash is of format:
        # {
        #   "1a6c1471-3efa-40bb-a807-5823008100f0": "British Embassy",
        #   "da231334-8790-3243-1111-5dsadasd2313": "British Embassy",...
        # }
        #
        #
        opportunity_to_providers = Hash[
          Opportunity.where(id: opportunity_ids).map{|op| [op.id, provider_names[op.service_provider_id]] }
        ]
      end

      def to_search_after(object, method)
        timestamp_str = format('%.6f', object.send(method).to_datetime.to_f)
        id_str = object.id.to_s
        "#{timestamp_str}_#{id_str}"
      end

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

      def respond(code, message)
        respond_to do |format|
          response.headers['Content-Type'] = 'application/json'
          error_object = {
            message: message,
          }
          format.json { render status: code, json: Yajl::Encoder.encode(error_object) }
        end
      end

      def respond_200(contents)
        respond_to do |format|
          response.headers['Content-Type'] = 'application/activity+json'
          format.json { render status: :ok, json: Yajl::Encoder.encode(contents) }
        end
      end
  end
end
