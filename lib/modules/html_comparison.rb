class HTMLComparison
  def tags?(text)
    scrubber = Rails::Html::TargetScrubber.new
    scrubber.tags = []
    scrubber.attributes = []
    normalized_text = Rails::Html::WhiteListSanitizer.new.sanitize(text, scrubber: scrubber)

    normalized_text == ActionController::Base.helpers.strip_tags(text)
  end
end
