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
    res = jwt_volume_connector_data(JSON.parse(token_response.body)['access_token'], hostname, data_endpoint, from_date, to_date)

    while res[:has_next]
      # store data from page
      process_result_page(res, editor)
      res = jwt_volume_connector_data(JSON.parse(token_response.body)['access_token'], res[:next_url], '', from_date, to_date)
    end

    # process the last page of results
    results = process_result_page(res, editor) if res[:data] && !res[:has_next]
    results
  end

  def calculate_value_id(gbp_value)
    return 3 if gbp_value.blank?

    value = gbp_value.to_i

    # set value to:
    # 2, less than 100k
    # 1, 100k-1m
    # 3, value unknown  (value_to_gbp returns -1)
    # 4, GBP1m-5m
    # 5, GBP5m-50m
    # 6, more than GBP50m,
    id = if value < 100_000 && value >= 0
           2
         elsif value >= 100_000 && value < 1_000_000
           1
         elsif value >= 1_000_000 && value < 5_000_000
           4
         elsif value >= 5_000_000 && value < 50_000_000
           5
         elsif value > 50_000_000
           6
         else
           3
         end
    id
  end

  def opportunity_params(opportunity)
    opportunity_release = opportunity['releases'][0]
    vo_countryname = opportunity_release['parties'][0]['address']['countryName']
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
    country = Country.where('name ilike ?', countryname).first

    tender_opportunity_release = opportunity_release['tender']
    opportunity_source = tender_opportunity_release['documents'][0]['title'] if tender_opportunity_release['documents'] && tender_opportunity_release['documents'][0]
  
    cpvs = []

    gbp_value = tender_opportunity_release['gbp_value']
    value_id = calculate_value_id(gbp_value)

    response_due_on = tender_opportunity_release['tenderPeriod']['endDate'] if tender_opportunity_release['tenderPeriod']
    description = tender_opportunity_release['description'].presence

    title = if tender_opportunity_release['title'].present?
              clean_title(tender_opportunity_release['title'])
            end

    buyer = opportunity_release['buyer']
    tender_url = nil

    tender_opportunity_release['documents']&.each do |document|
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
        tender_content: opportunity_release.to_json,
        first_published_at: Time.zone.parse(opportunity_release['date']),
        tender_url: tender_url,
        ocid: opportunity_release['ocid'],
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
      opportunity_params = opportunity_params(opportunity)

      # get language of opportunity
      opportunity_language = opportunity_params[:language] if opportunity_params && opportunity_params[:language]

      end_date_str = opportunity_params[:response_due_on] if opportunity_params && opportunity_params[:response_due_on]

      process_opportunity = if opportunity_params.nil?
                              false
                            elsif end_date_str.nil?
                              false
                            elsif end_date_str && (Time.zone.parse(end_date_str) < Time.zone.now)
                              false
                            elsif opportunity_params[:ocid].nil?
                              false
                            elsif opportunity_params[:description].nil?
                              false
                            elsif opportunity_params && opportunity_params[:ocid]
                              opportunity_doesnt_exist?(opportunity_params[:ocid])
                            end

      # count valid/invalid opps
      if opportunity_params && process_opportunity
        if VolumeOppsValidator.new.validate_each(opportunity_params)
          translate(opportunity_params, %i[description teaser title], opportunity_language) if should_translate?(opportunity_language)
          opportunity_params = enforce_sentence_case(opportunity_params)
          CreateOpportunity.new(editor, :publish, :volume_opps).call(opportunity_params)
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
