require 'jwt_volume_connector'
require 'translation_connector'

class VolumeOppsRetriever
  include ApplicationHelper

  def call(editor, from_date, to_date)
    username = Figaro.env.OO_USERNAME!
    password = Figaro.env.OO_PASSWORD!
    hostname = Figaro.env.OO_HOSTNAME!
    data_endpoint = Figaro.env.OO_DATA_ENDPOINT!
    token_endpoint = Figaro.env.OO_TOKEN_ENDPOINT!
    token_response = jwt_volume_connector_token(username, password, hostname, token_endpoint)
    res = jwt_volume_connector_data(JSON.parse(token_response.body)['token'], hostname, data_endpoint, from_date, to_date)

    while res[:has_next]
      # store data from page
      process_result_page(res, editor)
      res = jwt_volume_connector_data(JSON.parse(token_response.body)['token'], res[:next_url], '', from_date, to_date)
    end

    # process the last page of results
    results = process_result_page(res, editor) if res[:data] && !res[:has_next]
    results
  end

  def calculate_value(local_currency_value_hash)
    return { id: 3 } if local_currency_value_hash.blank?

    value = local_currency_value_hash['amount'].to_i
    currency_name = local_currency_value_hash['currency']

    return { id: 3 } if value.nil? || currency_name.nil?

    gbp_value = value_to_gbp(value, currency_name)
    # set value to:
    # 2, less than 100k
    # 1, 100k-1m
    # 3, value unknown  (value_to_gbp returns -1)
    # 4, GBP1m-5m
    # 5, GBP5m-50m
    # 6, more than GBP50m,
    id = if gbp_value < 100_000 && gbp_value >= 0
           2
         elsif gbp_value >= 100_000 && gbp_value < 1_000_000
           1
         elsif gbp_value >= 1_000_000 && gbp_value < 5_000_000
           4
         elsif gbp_value >= 5_000_000 && gbp_value < 50_000_000
           5
         elsif gbp_value > 50_000_000
           6
         else
           3
         end
    { id: id, gbp_value: gbp_value }
  end

  def opportunity_params(opportunity)
    vo_countryname = opportunity['countryname']
    # in these four corner cases we store country name in a significantly different way than the ISO name, so we need to transform ISO name -> ExOpps name
    countryname = case vo_countryname
                  when 'United States'
                    'USA'
                  when 'China, People\'s Republic of'
                    'China'
                  when 'China, Republic of (Taiwan)'
                    'Taiwan'
                  when 'United Arab Emirates'
                    'UAE'
                  else
                    vo_countryname
                  end
    country = Country.where('name like ?', countryname).first

    opportunity_release = opportunity['json']['releases'][0]
    opportunity_source = opportunity['source']

    tender_opportunity_release = opportunity_release['tender']
    tender_opportunity_release = tender_opportunity_release['items'] if tender_opportunity_release
    cpvs = []

    tender_opportunity_release&.each do |each_tender_opportunity_release|
      classification_tender_opportunity_release = each_tender_opportunity_release['classification']

      cpv = classification_tender_opportunity_release['id'].to_i if classification_tender_opportunity_release
      cpv_obj = CategorisationMicroservice.new(cpv).call
      cpv_with_description = if cpv_obj && cpv_obj[0] && cpv_obj[0]['cpv_description']
                               "#{cpv}: #{cpv_obj[0]['cpv_description']}"
                             else
                               cpv
                             end
      cpv_scheme = classification_tender_opportunity_release['scheme'] if classification_tender_opportunity_release
      cpvs << { industry_id: cpv_with_description, industry_scheme: cpv_scheme } if cpv
    end

    if opportunity_release['planning'] && opportunity_release['planning']['budget']
      values = calculate_value(opportunity_release['planning']['budget']['amount'])
      value_id = values[:id]
      gbp_value = values[:gbp_value]
    else
      # value unknown
      value_id = 3
    end
    response_due_on = opportunity_release['tender']['tenderPeriod']['endDate'] if opportunity_release['tender']['tenderPeriod']
    description = opportunity_release['tender']['description'].presence

    title = if opportunity_release['tender']['title'].present?
              clean_title(opportunity_release['tender']['title'])
            end

    buyer = opportunity_release['buyer']
    tender_url = nil

    opportunity_release['tender']['documents']&.each do |document|
      tender_url = document['url'].to_s if document['id'].eql?('tender_url')
    end

    # TODO: change to ted_published_date
    # published_date = if opportunity_source.eql?('ted_notices')
    #                    opportunity['releasedate']
    #                  else
    #                    opportunity['pubdate']
    #                  end
    if country && tender_url.present?
      {
        title: title,
        country_ids: country.id,
        sector_ids: [],
        type_ids: ['2'], # type is always public
        value_ids: value_id,
        teaser: nil,
        response_due_on: response_due_on,
        description: description,
        service_provider_id: 27, # DIT HQ
        contacts_attributes: contact_attributes(buyer),
        buyer_name: buyer['name'],
        buyer_address: buyer['address'].present? ? address_from_buyer(buyer['address']) : nil,
        language: opportunity_release['language'].presence,
        tender_value: gbp_value.present? ? Integer(gbp_value).floor : nil,
        source: :volume_opps,
        tender_content: opportunity['json'].to_json,
        first_published_at: nil,
        tender_url: tender_url,
        ocid: opportunity['ocid'],
        tender_source: opportunity_source,
        cpvs: cpvs,
      }
    else
      nil
    end
  end

  # removing nbsp and other breaking characters
  def sanitise(description)
    description = description.gsub(/[[:space:]]+/, ' ')
    description.gsub(/&nbsp;/i, ' ')
  end

  def address_from_buyer(address)
    str = ''
    str += " #{address['streetAddress']}" if address['streetAddress']
    str += " #{address['locality']}" if address['locality']
    str += " #{address['postalCode']}" if address['postalCode']
    str + " #{address['countryName']}" if address['countryName']
  end

  def contact_attributes(buyer)
    empty_hash = [
      {
        name: nil,
        email: nil,
      },
      {
        name: nil,
        email: nil,
      },
    ]

    if buyer['contactPoint']
      name = if buyer['contactPoint']['name']
               buyer['contactPoint']['name']
             elsif buyer['name']
               buyer['name']
             else
               'NOT APPLICABLE'
             end
      email = buyer['contactPoint']['email'] || ''

      return [
        {
          name: name,
          email: email,
        },
      ]
    end

    empty_hash
  end

  def jwt_volume_connector_token(username, password, hostname, token_endpoint)
    JwtVolumeConnector.new.token(username, password, hostname, token_endpoint)
  end

  def jwt_volume_connector_data(token, hostname, url, from_date, to_date)
    JwtVolumeConnector.new.data(token, hostname, url, from_date, to_date)
  rescue JSON::ParserError => e
    redis = Redis.new(url: Figaro.env.REDIS_URL!)
    redis.set(:application_error, Time.zone.now)

    raise e
  end

  def process_result_page(res, editor)
    # counters for valid/invalid opps
    invalid_opp = 0
    valid_opp = 0
    invalid_opp_params = 0

    res[:data].each do |opportunity|
      # get language of opportunity
      opportunity_language = opportunity['language']

      opportunity_params = opportunity_params(opportunity)

      process_opportunity = if opportunity_params && opportunity_params[:ocid]
                              opportunity_doesnt_exist?(opportunity_params[:ocid])
                            elsif opportunity_params.nil?
                              false
                            elsif opportunity_params[:ocid].nil?
                              false
                            end

      # count valid/invalid opps
      if opportunity_params && process_opportunity
        if VolumeOppsValidator.new.validate_each(opportunity_params)
          translate(opportunity_params, %i[description teaser title], opportunity_language) if should_translate?(opportunity_language)
          opportunity_params = enforce_sentence_case(opportunity_params)
          CreateOpportunity.new(editor, :draft, :volume_opps).call(opportunity_params)
          valid_opp += 1
        else
          invalid_opp += 1
        end
      else
        invalid_opp_params += 1
      end
    end
  end

  def clean_title(title)
    length = title.length
    if length > 250
      "#{title[0, 247]}..."
    elsif length <= 250 && title[-1] == '.'
      # if it ends with ., remove the dot
      title[0...-1]
    else
      title
    end
  end

  def translate(opportunity_params, fields, original_language)
    hostname = Figaro.env.DL_HOSTNAME!
    api_key = Figaro.env.DL_API_KEY!
    TranslationConnector.new.call(opportunity_params, fields, original_language, hostname, api_key)
  end

  def enforce_sentence_case(opportunity_params)
    SentenceCaseEnforcer.new(opportunity_params).call
  end

  # language has to NOT be english
  # language has to be supported by our translation engine
  # language translation feature flag should be set to 'true'
  def should_translate?(language)
    !((language != 'en') ^ (language != 'en-GB')) && ActiveModel::Type::Boolean.new.cast(Figaro.env.TRANSLATE_OPPORTUNITIES) && SUPPORTED_LANGUAGES.include?(language)
  end

  private

    def value_to_gbp(value, currency)
      @exchange_rates ||= begin
        JSON.parse(File.read('db/seed_data/exchange_rates.json'))
                          # response = Net::HTTP.get_response(URI.parse(Figaro.env.EXCHANGE_RATE_URI))
                          # JSON.parse(response.body)
                          rescue StandardError
                            JSON.parse(File.read('db/seed_data/exchange_rates.json'))
      end

      # base rate is USD, we need to convert to GBP
      gbp_rate = @exchange_rates['rates']['GBP']
      rate = @exchange_rates['rates'][currency]
      if rate
        ((value / rate) * gbp_rate).floor(2)
      else
        -1
      end
    end

    def opportunity_doesnt_exist?(ocid)
      raise unless ocid

      count = Opportunity.where(ocid: ocid).count
      if count.zero?
        true
      else
        false
      end
    end
end
