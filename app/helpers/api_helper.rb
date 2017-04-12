module ApiHelper
  def format_date(attribute)
    attribute.to_date if attribute.present?
  end

  def format_datetime(attribute)
    attribute.iso8601 if attribute.present?
  end
end
