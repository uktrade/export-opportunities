module Admin
  class StatsController < BaseController
    def index
      authorize :stats
      search_params = stats_search_form_params
      default_service_provider = current_editor.service_provider&.id
      if default_service_provider then default_country = current_editor.service_provider.country&.id end
      if default_country then default_region = current_editor.service_provider.country.region&.id end
      default_granularity = 'Universe'

      search_params[:service_provider] ||= default_service_provider
      search_params[:country] ||= default_country
      search_params[:region] ||= default_region
      search_params[:granularity] ||= default_granularity

      @stats_search_form = StatsSearchForm.new(search_params)
      if @stats_search_form.valid?
        @stats = StatsPresenter.new(StatsCalculator.new.call(@stats_search_form))
        @service_provider = load_service_provider(@stats_search_form)
        @country = load_country(@stats_search_form)
        @region = load_region(@stats_search_form)
        render 'index.success'
      else
        render 'index.errors'
      end
    end

    def show
      authorize :stats

      today = DateTime.now.utc
      last_month = today - 1.month
      redirect_to "/admin/stats?stats_from%5Byear%5D=#{last_month.year}&stats_from%5Bmonth%5D=#{last_month.month}&stats_from%5Bday%5D=#{last_month.day}&stats_to%5Byear%5D=#{today.year}&stats_to%5Bmonth%5D=#{today.month}&stats_to%5Bday%5D=#{today.day}&service_provider=all&granularity=Universe"
    end

    private

    def stats_search_form_params
      params_for_date_select = [:year, :month, :day]
      params.permit(
        :service_provider,
        :country,
        :region,
        :granularity,
        stats_to: params_for_date_select,
        stats_from: params_for_date_select
      )
    end

    def load_service_provider(search_form)
      if search_form.all_service_providers?
        StatsSearchForm::AllServiceProviders
      else
        ServiceProvider.find(search_form.service_provider_id)
      end
    end

    def load_country(search_form)
      Country.find(search_form.country_id)
    end

    def load_region(search_form)
      Region.find(search_form.region_id)
    end
  end
end
