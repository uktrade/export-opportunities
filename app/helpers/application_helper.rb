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

  def trade_profile(companies_house_number)
    return nil unless companies_house_number
    trade_profile_url = Figaro.env.TRADE_PROFILE_PAGE + companies_house_number
    response = Net::HTTP.get(URI(trade_profile_url))
    # TODO: Profile Team should return a proper HTTP code in response
    trade_profile_url if response.eql?('')
  end
end
