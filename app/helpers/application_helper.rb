require 'net/http'

module ApplicationHelper
  def present_html_or_formatted_text(text)
    return '' if text.blank?
    return simple_format(text) if html_tags?(text)
    sanitize(text)
  end

  def promote_elements_to_front_of_array(array, selected_elements = [])
    selected_elements + (array - selected_elements)
  end

  def companies_house_url(companies_house_number)
    return nil if companies_house_number.blank?
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
    trade_profile_url = Figaro.env.TRADE_PROFILE_PAGE + companies_house_number + '/'
    begin
      response = Net::HTTP.get_response(URI.parse(trade_profile_url.to_s))
    rescue
      response = nil
    end
    if response.nil? || response.code == '404'
      return nil
    else
      return trade_profile_url
    end
  end

  def opportunity_expired?(response_due_on)
    response_due_on < Time.zone.now - 7.days
  end

  private def html_tags?(text)
    scrubber = Rails::Html::TargetScrubber.new
    scrubber.tags = []
    scrubber.attributes = []
    normalized_text = Rails::Html::WhiteListSanitizer.new.sanitize(text, scrubber: scrubber)

    normalized_text == ActionController::Base.helpers.strip_tags(text)
  end
end
