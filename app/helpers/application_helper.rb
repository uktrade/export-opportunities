require 'net/http'

module ApplicationHelper
  def present_html_or_formatted_text(text)
    return '' if text.blank?
    return simple_format(text) if html_tags?(text)
    sanitize(text)
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

  def cpv_description(cpv_id)
    return nil unless cpv_id
    cpv_description_microservice_url = Figaro.env.CPV_TRANSLATOR_URL + '/api/v1/cpv/' + cpv_id.to_s
    begin
      json = JSON.parse(Net::HTTP.get(URI(cpv_description_microservice_url)))
      response = json
    rescue
      response = nil
    end
    response
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

  # removing nbsp and other breaking characters
  def sanitise_opportunity_text(description)
    return nil unless description
    description = description.gsub(/[[:space:]]+/, ' ')
    description.gsub(/&nbsp;/i, ' ')
  end
end
