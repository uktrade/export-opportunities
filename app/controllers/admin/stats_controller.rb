module Admin
  class StatsController < BaseController
    def index
      authorize :stats
      search_params = stats_search_form_params
      search_params[:ServiceProvider]
      search_params[:Country]
      search_params[:Region]
      search_params[:granularity]
      search_params[:sources]

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
      params.permit!
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
