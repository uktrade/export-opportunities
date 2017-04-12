module Users
  class DashboardController < BaseController
    def index
      redirect_to(Figaro.env.SUD_PROFILE_PAGE) if Rails.env.production?

      @enquiries = current_user.enquiries.includes(:opportunity)
      @subscriptions = current_user.subscriptions.includes(:types, :values, :countries, :sectors).active
      @subscriptions = @subscriptions.map { |sub| SubscriptionPresenter.new(sub) }
    end
  end
end
