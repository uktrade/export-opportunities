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
    rescue StandardError
      response = nil
    end
    response
  end

  def trade_profile(companies_house_number)
    return nil unless companies_house_number

    trade_profile_url = Figaro.env.TRADE_PROFILE_PAGE + companies_house_number + '/'
    begin
      response = Net::HTTP.get_response(URI.parse(trade_profile_url.to_s))
    rescue StandardError
      response = nil
    end
    if response.nil? || response.code == '404'
      nil
    else
      trade_profile_url
    end
  end

  def opportunity_expired?(response_due_on)
    response_due_on < Time.zone.now - 7.days
  end

  def page_title
    @page_title || t('site_name')
  end

  def canonical_tag(url)
    tag(:link, rel: "canonical", href: url)
  end

  def hreflang_tags(url)
    [
      tag(:link, rel: "alternate", hreflang: "en-gb", href: url),
      tag(:link, rel: "alternate", hreflang: "x-default", href: root_url)
    ].join("\n").html_safe
  end

  private

    def html_tags?(text)
      scrubber = Rails::Html::TargetScrubber.new
      scrubber.tags = []
      scrubber.attributes = []
      normalized_text = Rails::Html::WhiteListSanitizer.new.sanitize(text, scrubber: scrubber)

      normalized_text == ActionController::Base.helpers.strip_tags(text)
    end
end
