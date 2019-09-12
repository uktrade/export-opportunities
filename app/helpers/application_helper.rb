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

  def opportunity_expired?(response_due_on)
    response_due_on < Time.zone.now - 7.days
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
