class StatsSearchForm
  attr_reader :service_provider_id
  attr_reader :country_id
  attr_reader :region_id
  attr_reader :granularity
  attr_reader :error_messages

  AllServiceProviders = Struct.new(:name, :id).new('all service providers', 'all')

  def initialize(params)
    @service_provider_id = params[:ServiceProvider][':service_provider_ids'].reject { |e| e.to_s.empty? }.map(&:to_i) if params[:ServiceProvider]
    @country_id = params[:Country][':country_ids'].reject { |e| e.to_s.empty? }.map(&:to_i) if params[:Country]
    @region_id = params[:Region][':region_ids'].reject { |e| e.to_s.empty? }.map(&:to_i) if params[:Region]
    @granularity = params[:granularity]
    @from_date_field = SelectDateField.new(value: params[:stats_from], default: Time.zone.today - 30)
    @to_date_field = SelectDateField.new(value: params[:stats_to], default: Time.zone.today - 1)
    @error_messages = []
  end

  def valid?
    unless @service_provider_id.present? || @country_id.present? || @region_id.present? || @granularity == 'Universe'
      @error_messages << I18n.t('admin.stats.errors.missing_service_provider_country_or_region')
    end

    if @from_date_field.invalid?
      @error_messages << I18n.t('admin.stats.errors.invalid_date', field: 'From')
    end

    if @to_date_field.invalid?
      @error_messages << I18n.t('admin.stats.errors.invalid_date', field: 'To')
    end

    if @to_date_field.date < @from_date_field.date
      @error_messages << I18n.t('admin.stats.errors.dates_out_of_order')
    end

    @error_messages.empty?
  end

  def all_service_providers?
    'all' == service_provider_id
  end

  def service_providers
    ServiceProvider.order(name: :asc)
  end

  def countries
    Country.order(name: :asc)
  end

  def regions
    Region.order(name: :asc)
  end

  def date_from
    @from_date_field.date
  end

  def date_to
    @to_date_field.date
  end

  class SelectDateField
    attr_reader :date

    def initialize(value:, default:)
      @value = value || {}
      @date = parse_date || default
    end

    def invalid?
      @value.present? && (parse_date.nil? || date_out_of_range(parse_date))
    end

    def parse_date
      Date.new(@value[:year].to_i, @value[:month].to_i, @value[:day].to_i)
    rescue ArgumentError
      nil
    end

    def date_out_of_range(date)
      date.year < SITE_LAUNCH_YEAR || date.year > DateTime.current.year
    end
  end
end
