module Api
  class ProfileDashboardController < ApplicationController
    include RegionHelper
    protect_from_forgery with: :exception

    def index
      hashed_sso_id = params[:hashed_sso_id] || params[:sso_user_id]
      return bad_request! unless hashed_sso_id && params[:shared_secret]
      return forbidden! if params[:shared_secret] != Figaro.env.api_profile_dashboard_shared_secret
      user = User.find_by(sso_hashed_uuid: hashed_sso_id)
      return forbidden! if user.nil?

      @result = { status: 'ok', code: 200, enquiries: [], email_alerts: [] }
      @enquiries = user.enquiries.includes(:opportunity)
      @result[:enquiries] = result_enquiries(@enquiries)
      @subscriptions = user.subscriptions.includes(:types, :values, :countries, :sectors).active
      @result[:email_alerts] = result_subscriptions(@subscriptions)
      
      respond_to do |format|
        format.json { render status: :ok, json: @result }
      end
    end

    def opportunities
      return bad_request! unless params[:hashed_sso_id] && params[:shared_secret]
      return forbidden! if params[:shared_secret] != Figaro.env.api_profile_dashboard_shared_secret

      hashed_sso_id = params[:hashed_sso_id]

      @result = { status: 'ok', code: 200, enquiries: [], email_alerts: [] }

      user = User.find_by(sso_hashed_uuid: hashed_sso_id)
      return forbidden! if user.nil?

      result = Search.new(params,
                          limit: 500,
                          results_only: true,
                          sort: 'updated_at').run
      @result[:relevant_opportunities] = if result.records.any?
        result.map do |opportunity|
          {
            title: opportunity.title,
            url: opportunity_url(opportunity.slug),
            description: opportunity.description,
            published_date: opportunity.first_published_at,
            closing_date: opportunity.response_due_on,
            source: opportunity.source
          }
        end
      else
        []
      end
      respond_to do |format|
        format.json { render status: :ok, json: @result }
      end
    end

    private

      def result_enquiries(enquiries)
        enquiries.map do |enq|
          {
            title: enq.opportunity.title,
            opportunity_url: opportunity_url(enq.opportunity.slug),
            description: enq.opportunity.description,
            submitted_on: enq.created_at,
            expiration_date: enq.opportunity.response_due_on,
            enquiry_url: dashboard_enquiry_url(enq.id),
          }
        end
      end

      def result_subscriptions(subscriptions)
        subscriptions.map do |sub|
          {
            term: sub.search_term,
            created_on: sub.created_at,
            unsubscribe_url: unsubscribe_url(sub.id),
            title: sub.title,
            countries: sub.countries.map(&:slug),
          }
        end
      end

      def bad_request!
        render status: :bad_request, json: { status: 'Bad Request', code: 400 }.freeze
      end

      def forbidden!
        render status: :forbidden, json: { status: 'Forbidden', code: 403 }.freeze
      end

      def internal_error!
        render status: :internal_server_error, json: { status: 'Internal Error', code: 500 }.freeze
      end
  end
end
