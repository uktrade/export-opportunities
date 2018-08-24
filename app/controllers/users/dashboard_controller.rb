module Users
  class DashboardController < BaseController
    def index
      if Rails.env.production?
        if params[:target] == 'alerts'
          redirect_to(ENV['SUD_PROFILE_PAGE_EMAIL_ALERTS'])
        else
          redirect_to(ENV['SUD_PROFILE_PAGE'])
        end
      end

      @enquiries = current_user.enquiries.includes(:opportunity)
      @subscriptions = current_user.subscriptions.includes(:types, :values, :countries, :sectors).active
      @subscriptions = @subscriptions.map { |sub| SubscriptionPresenter.new(sub) }
    end
  end
end
