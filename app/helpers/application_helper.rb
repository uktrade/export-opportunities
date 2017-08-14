require 'net/http'

module ApplicationHelper
  def present_html_or_formatted_text(text)
    return '' unless text.present?
    return simple_format(text) if HTMLComparison.new.tags?(text)
    sanitize(text)
  end

  def promote_elements_to_front_of_array(array, selected_elements = [])
    selected_elements + (array - selected_elements)
  end

  def companies_house_url(companies_house_number)
    return nil if companies_house_number.nil? || companies_house_number.empty?
    companies_house_url = Figaro.env.COMPANIES_HOUSE_BASE_URL + companies_house_number
    begin
      response = companies_house_url if Net::HTTP.get(URI(companies_house_url))
    rescue
      response = nil
    end
    response
  end

  def trade_profile(companies_house_number)
    return nil unless companies_house_number
    trade_profile_url = Figaro.env.TRADE_PROFILE_PAGE + companies_house_number
    begin
      response = Net::HTTP.get(URI(trade_profile_url))
    rescue
      response = nil
    end
    # TODO: Profile Team should return a proper HTTP code in response
    trade_profile_url if response.eql?('')
  end

  def is_opportunity_expired(response_due_on)
    if (response_due_on < Time.zone.now-7.days)
      response = true
    else
      response = false
    end
    response
  end

end
