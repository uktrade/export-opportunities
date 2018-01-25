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
      # byebug
      country = Country.where('name like ?', opportunity['countryname']).first

      value_id = if opportunity['json']['releases'][0]['tender']['value']
                   calculate_value(opportunity['json']['releases'][0]['tender']['value'])
                 else
                   3
                 end
      response_due_on = opportunity['json']['releases'][0]['tender']['tenderPeriod']['endDate'] if opportunity['json']['releases'][0]['tender']['tenderPeriod']
        CreateOpportunity.new(editor).call(
                                         {
                                          title: opportunity['json']['releases'][0]['tender']['title'],
                                          country_ids: 11, #country.id,
                                          sector_ids: ['2'],
                                          type_ids: ['3'],
                                          value_ids: value_id,
                                          teaser: opportunity['json']['releases'][0]['tender']['description'],
                                          response_due_on: response_due_on,
                                          description: opportunity['json']['releases'][0]['tender']['description'],
                                          service_provider_id: 5,
                                          contacts_attributes: [
                                              { name: 'foo', email: 'email@foo.com' },
                                              { name: 'bar', email: 'email@bar.com' },
                                              ]
                                         }
        )
        # check DB (indexed column) for ocid entry (later, compare diff if its an update on tender's status)

        # get relevant fields from OO opp
        # save into our DB
      end
      res = JwtVolumeConnector.new.data(JSON.parse(token_response.body)['token'], res[:next_url], '')
    end
  end

  private def calculate_value(local_currency_value_hash)

    value = local_currency_value_hash['amount']
    currency_name = local_currency_value_hash['currency']
    gbp_value = value_to_gbp(value)
    if gbp_value < 100000
      1
    else
      2
    end
  end

  private def value_to_gbp(value)
    return 50000
  end

  def opportunity_params(title: 'title')
    {
        title: title,
        country_ids: ['11'],
        sector_ids: ['2'],
        type_ids: ['3'],
        value_ids: ['4'],
        teaser: 'teaser',
        response_due_on: '2015-02-01',
        description: 'description',
        contacts_attributes: [
            { name: 'foo', email: 'email@foo.com' },
            { name: 'bar', email: 'email@bar.com' },
        ],
        service_provider_id: '5',
    }
  end
end
