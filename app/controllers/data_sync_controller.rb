class DataSyncController < ApplicationController
  # Protect by basic auth on staging
  # Use basic auth if set in the environment
  before_action :basic_auth

  #
  # basic checks for data sync between ES and PG DB
  # Redis has a key 'es_data_sync_error_ts' that stores the first time it timed out
  # for this outage
  #
  def check
    # Set up redis
    @redis = Redis.new(url: Figaro.env.redis_url)
    response = { git_revision: ExportOpportunities::REVISION, status: 'OK', status_code: 200 }

    # Do databases match? If not, save disparity data to 'result' key
    response[:result] = missing_data

    if response[:result].empty?
      # unset the counter when data is back in sync
      @redis.del(:es_data_sync_error_ts)
    elsif (timeout = @redis.get(:es_data_sync_error_ts)).blank?
      # set new timer start
      @redis.set(:es_data_sync_error_ts, Time.now.utc)
    else
      response[:timeout_sec] = (Time.now.utc - Time.zone.parse(timeout)).floor

      # Report error after 10 minutes
      if response[:timeout_sec] > 600.freeze
        response[:status] = 'error'
        response[:status_code] = 500
      end
    end

    render json: response, status: response[:status_code]
  end

  private

    def missing_data
      missing = {}
      if (ops = databases_match_opportunities?) != true
        missing['opportunities'] = ops
      end
      if (subs = databases_match_subscriptions?) != true
        missing['subscriptions'] = subs
      end
      missing
    end

    def databases_match_opportunities?
      # 'db' is the relational database, e.g. PostgreSQL
      db = db_opportunities
      es = es_opportunities

      if db.size == es.size
        true
      else
        missing = db - es | es - db
        Rails.logger.error('we are missing opportunities')
        Rails.logger.error(missing)
        { expected_opportunities: db.size, actual_opportunities: es.size, missing: missing }
      end
    end

    def databases_match_subscriptions?
      # 'db' is the  relational database, e.g. PostgreSQL
      db = db_subscriptions
      es = es_subscriptions

      if db.size == es.size
        true
      else
        missing = db - es | es - db
        Rails.logger.error('we are missing subscriber docs')
        Rails.logger.error(missing)
        { expected_opportunities: db.size, actual_opportunities: es.size, missing: missing }
      end
    end

    def db_opportunities
      Opportunity.where('response_due_on >= ? and status = ?', DateTime.now.utc, 2).pluck(:id)
    end

    def es_opportunities
      query = OpportunitySearchBuilder.new.call
      res = []
      es_opportunities = Opportunity.__elasticsearch__.search(size: 100_000, query: query[:query], sort: query[:sort])
      es_opportunities.each { |record| res.push record.id }
      res
    end

    def db_subscriptions
      Subscription.count
    end

    def es_subscriptions
      Subscription.__elasticsearch__.count
    end
end
