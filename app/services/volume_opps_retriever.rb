require 'jwt_volume_connector'

class VolumeOppsRetriever
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
    process_result_page(res, editor) if res[:data] && !res[:has_next]
  end

  def calculate_value(local_currency_value_hash)
    value = local_currency_value_hash['amount']
    currency_name = local_currency_value_hash['currency']

    return { id: 2 } if value.nil? || currency_name.nil?

    gbp_value = value_to_gbp(value, currency_name)
    # set value to 1<100,000GBP or 3>100,000GBP
    id = if gbp_value < 100_000
           1
         else
           3
         end
    { id: id, gbp_value: gbp_value }
  end

  def opportunity_params(opportunity)
    country = Country.where('name like ?', opportunity['countryname']).first
    opportunity_release = opportunity['json']['releases'][0]
    opportunity_source = opportunity['source']

    tender_opportunity_release = opportunity_release['tender']
    tender_opportunity_release = tender_opportunity_release['items'] if tender_opportunity_release
    opportunity_cpvs = []

    tender_opportunity_release&.each do |each_tender_opportunity_release|
      classification_tender_opportunity_release = each_tender_opportunity_release['classification']

      cpv = classification_tender_opportunity_release['id'].to_i if classification_tender_opportunity_release
      cpv_scheme = classification_tender_opportunity_release['scheme'] if classification_tender_opportunity_release

      opportunity_cpvs << { industry_id: cpv, industry_scheme: cpv_scheme }
    end

    if opportunity_release['planning'] && opportunity_release['planning']['budget']
      values = calculate_value(opportunity_release['planning']['budget']['amount'])
      value_id = values[:id]
      gbp_value = values[:gbp_value]
    else
      # value unknown
      value_id = 2
    end
    response_due_on = opportunity_release['tender']['tenderPeriod']['endDate'] if opportunity_release['tender']['tenderPeriod']
    description = if opportunity_release['tender']['description'].present?
                    opportunity_release['tender']['description']
                  elsif opportunity_release['tender']['title'].present?
                    opportunity_release['tender']['title']
                  end

    title = if opportunity_release['tender']['title'].present?
              clean_title(opportunity_release['tender']['title'])
            end

    buyer = opportunity_release['buyer']
    tender_url = nil

    opportunity_release['tender']['documents']&.each do |document|
      tender_url = document['url'].to_s if document['id'].eql?('tender_url')
    end

    published_date = if opportunity_source.eql?('ted_notices')
                       opportunity['releasedate']
                     else
                       opportunity['pubdate']
                     end

    if description && country && tender_url
      {
        title: title,
        country_ids: country.id,
        sector_ids: ['2'],
        type_ids: ['2'], # type is always public
        value_ids: value_id,
        teaser: nil,
        response_due_on: response_due_on,
        description: description,
        service_provider_id: 150,
        contacts_attributes: contact_attributes(buyer),
        buyer_name: buyer['name'],
        buyer_address: buyer['address'].present? ? address_from_buyer(buyer['address']) : nil,
        language: opportunity_release['language'].present? ? opportunity_release['language'] : nil,
        tender_value: gbp_value.present? ? Integer(gbp_value).floor : nil,
        source: :volume_opps,
        tender_content: opportunity['json'].to_json,
        first_published_at: published_date,
        tender_url: tender_url,
        ocid: opportunity['ocid'],
        tender_source: opportunity_source,
        opportunity_cpvs: opportunity_cpvs,
      }
    else
      return nil
    end
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
      name = buyer['contactPoint']['name']
      email = buyer['contactPoint']['email']

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
  end

  def process_result_page(res, editor)
    # counters for valid/invalid opps
    invalid_opp = 0
    valid_opp = 0
    invalid_opp_params = 0
    res[:data].each do |opportunity|
      Rails.logger.info '.....we have ' + valid_opp.to_s + ' valid opps and ' + invalid_opp.to_s + ' invalid opps and ' + invalid_opp_params.to_s + ' invalid opp params already.....'
      opportunity_params = opportunity_params(opportunity)

      # count valid/invalid opps
      if opportunity_params
        if VolumeOppsValidator.new.validate_each(opportunity_params)
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

  private def value_to_gbp(value, currency)
    @exchange_rates ||= begin
      JSON.parse(File.read('db/seed_data/exchange_rates.json'))
      # response = Net::HTTP.get_response(URI.parse(Figaro.env.EXCHANGE_RATE_URI))
      # JSON.parse(response.body)
    rescue
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
end
