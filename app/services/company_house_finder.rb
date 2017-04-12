class CompanyHouseFinder
  API_URL = 'https://api.companieshouse.gov.uk/'.freeze

  def call(search_terms)
    results = search_companies(search_terms)
    if response_valid?(results)
      return results['items'].map { |company| CompanyDetail.new(company.to_h) }
    else
      Rails.logger.warn "Companies House API returning invalid data: \n\t\t" + results.inspect
      return []
    end
  end

  private def response_valid?(results)
    results.present? && results.key?('items') && !results['items'].empty?
  end

  private def search_companies(company)
    uri = api_uri(company)

    # The duplication in creating a URI and then setting `basic_auth`
    # is because we need an explicitly set empty password in the URL.
    # Without setting the password explicitly to an empty string, it'll
    # request the wrong thing.

    req = Net::HTTP::Get.new(uri)
    req.basic_auth api_key, ''
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    if res.code == '200' && res.body.present? && !res.body.empty?
      begin
        return JSON.parse(res.body)
      rescue JSON::ParserError
        Rails.logger.warn 'Companies House API returning invalid JSON:\n\t\t' + res.body
        return {}
      end
    else
      return {}
    end
  end

  private def api_key
    @api_key ||= Figaro.env.companies_house_api_token!
  end

  private def api_uri(company = '')
    uri = URI(API_URL)
    uri.path = '/search/companies'
    uri.query = URI.encode_www_form('q': company)
    uri.user = api_key
    uri.password = ''
    uri
  end
end
