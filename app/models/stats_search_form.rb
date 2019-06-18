class StatsSearchForm
  attr_reader :service_provider_id
  attr_reader :country_id
  attr_reader :region_id
  attr_reader :granularity
  attr_reader :error_messages
  attr_reader :source

  AllServiceProviders = Struct.new(:name, :id).new('all service providers', 'all')

  def initialize(params)
    @from_date_field = SelectDateField.new(value: params[:stats_from], default: Time.zone.today - 30)
    @to_date_field = SelectDateField.new(value: params[:stats_to], default: Time.zone.today - 1)
    @granularity = GranularityField.new(params[:granularity])
    @source = SourceField.new(params[:post], params[:third_party], params[:granularity].nil?)

    @region_id = params[:Region] && params[:Region]['region_ids'].map(&:to_i) || []
    @country_id = params[:Country] && params[:Country]['country_ids'].map(&:to_i) || []
    @service_provider_id = params[:ServiceProvider] && params[:ServiceProvider]['service_provider_ids'].map(&:to_i) || []

    @error_messages = []
  end

  def valid?
    unless @service_provider_id.present? || @country_id.present? || @region_id.present? || @granularity.value == 'Universe'
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
    service_provider_id == 'all'
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

  def sources
    %i[post volume_opps]
  end

  def to_h
    if @source.value.eql?(:post)
      'DIT'
    elsif @source.value.eql?(:volume_opps)
      'Third party'
    else
      'all sources'
    end
  end

  def was_submitted?
    @granularity.value.present?
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

  class GranularityField
    attr_reader :options, :value

    def initialize(value)
      @value = value
      @options = create_options(value)
    end

    private

      def create_options(value)
        options = [
          {
            label: { text: 'All' },
            value: 'Universe',
            checked: true,
          },
          {
            label: { text: 'Region' },
            value: 'Region',
            checked: false,
          },
          {
            label: { text: 'Country' },
            value: 'Country',
            checked: false,
          },
          {
            label: { text: 'Service Provider' },
            value: 'ServiceProvider',
            checked: false,
          },
        ]

        if value.present?
          options.each do |option|
            option['checked'] = (option['value'] == value)
          end
        end

        options
      end
  end

  class SourceField
    attr_reader :options, :value

    def initialize(post, third_party, use_default_state)
      @options = create_options(post, third_party, use_default_state)
      @value = if post && third_party
                 nil
               elsif post
                 :post
               elsif third_party
                 :volume_opps
               end
    end

    private

      def create_options(post_selected, third_party_selected, use_default_state)
        post_checked = if use_default_state
                         true
                       else
                         post_selected
                       end
        third_party_checked = if use_default_state
                                true
                              else
                                third_party_selected
                              end
        [
          {
            label: { text: 'DIT' },
            name: 'post',
            value: '1',
            checked: post_checked,
          },
          {
            label: { text: 'Third party' },
            name: 'third_party',
            value: '1',
            checked: third_party_checked,
          },
        ]
      end
  end
end
