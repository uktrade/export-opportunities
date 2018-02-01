class VolumeOppsRetriever
  def call(editor)
    username = Figaro.env.OO_USERNAME!
    password = Figaro.env.OO_PASSWORD!
    hostname = Figaro.env.OO_HOSTNAME!
    data_endpoint = Figaro.env.OO_DATA_ENDPOINT!
    token_endpoint = Figaro.env.OO_TOKEN_ENDPOINT!

    token_response = JwtVolumeConnector.new.token(username, password, hostname, token_endpoint)
    res = JwtVolumeConnector.new.data(JSON.parse(token_response.body)['token'], hostname, data_endpoint)

    while res[:has_next]
      # store data from page
      res[:data].each do |opportunity|
        opportunity_params = opportunity_params(opportunity)

        if opportunity_params
          next unless VolumeOppsValidator.new.valid?(opportunity_params)
          CreateOpportunity.new(editor, :publish).call(opportunity_params)
        end
      end
      res = JwtVolumeConnector.new.data(JSON.parse(token_response.body)['token'], res[:next_url], '')
    end
  end

  private def calculate_value(local_currency_value_hash)
    value = local_currency_value_hash['amount']
    currency_name = local_currency_value_hash['currency']
    gbp_value = value_to_gbp(value, currency_name)
    id = if gbp_value < 100_000
           1
         else
           2
         end
    { id: id, gbp_value: gbp_value }
  end

  private def value_to_gbp(value, currency)
    exchange_rates ||= begin
      response = Net::HTTP.get_response(URI.parse('https://openexchangerates.org/api/latest.json?app_id=2573237889fa4af8b07839c4c569fa08'))
      JSON.parse(response.body)
    rescue
      { 'status': '404' }
    end

    # base rate is USD, we need to convert to GBP
    gbp_rate = exchange_rates['rates']['GBP']
    rate = exchange_rates['rates'][currency]
    if rate
      (value / rate) * gbp_rate
    else
      -1
    end
  end

  def opportunity_params(opportunity)
    country = Country.where('name like ?', opportunity['countryname']).first

    if opportunity['json']['releases'][0]['tender']['value']
      values = calculate_value(opportunity['json']['releases'][0]['tender']['value'])
      value_id = values[:id]
      gbp_value = values[:gbp_value]
    else
      value_id = 3
    end
    response_due_on = opportunity['json']['releases'][0]['tender']['tenderPeriod']['endDate'] if opportunity['json']['releases'][0]['tender']['tenderPeriod']
    description = opportunity['json']['releases'][0]['tender']['description']
    buyer = opportunity['json']['releases'][0]['buyer']

    if description && country
      {
        title: opportunity['json']['releases'][0]['tender']['title'][0, 80],
        country_ids: country.id,
        sector_ids: ['2'],
        type_ids: ['3'], # type is always public
        value_ids: value_id,
        teaser: description[0, 140],
        response_due_on: response_due_on,
        description: description,
        service_provider_id: 5,
        contacts_attributes: [
          { name: buyer['contactPoint'].present? ? buyer['contactPoint']['name'] : nil,
            email: buyer['contactPoint'].present? ? buyer['contactPoint']['email'] : nil },
        ],
        buyer: buyer['name'],
        language: opportunity['json']['releases'][0]['language'].present? ? opportunity['json']['releases'][0]['language'] : nil,
        tender_value: gbp_value.present? ? Integer(gbp_value).floor : nil,
        source: 1,
        tender_content: opportunity['json'].to_json,
      }
    else
      return nil
    end
  end
end
