module Api
  class ProfileDashboardController < ApplicationController
    include RegionHelper
    protect_from_forgery with: :exception

    def index
      return bad_request! unless params[:sso_user_id] && params[:shared_secret]
      return forbidden! if params[:shared_secret] != Figaro.env.api_profile_dashboard_shared_secret

      user_id = params[:sso_user_id].to_i

      @result = { status: 'ok', code: 200, enquiries: [], email_alerts: [] }

      user = User.find_by uid: user_id
      return forbidden! if user.nil?

      @enquiries = user.enquiries.includes(:opportunity)
      @result[:enquiries] = @enquiries.map do |enq|
        {
          title: enq.opportunity.title,
          opportunity_url: opportunity_url(enq.opportunity.slug),
          description: enq.opportunity.description,
          submitted_on: enq.created_at,
          expiration_date: enq.opportunity.response_due_on,
          enquiry_url: dashboard_enquiry_url(enq.id),
        }
      end

      @subscriptions = user.subscriptions.includes(:types, :values, :countries, :sectors).active

      @result[:email_alerts] = @subscriptions.map do |sub|
        {
          term: sub.search_term,
          created_on: sub.created_at,
          unsubscribe_url: unsubscribe_url(sub.id),
          title: sub.title,
          countries: sub.countries.map(&:slug),
        }
      end
      respond_to do |format|
        format.json { render status: :ok, json: @result }
      end
    end

    private

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
