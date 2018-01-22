module EnquiryResponseHelper
  def to_h(response_type)
    case response_type
    when 1
      'Right for opportunity'
    when 2
      'Need more information'
    when 3
      'Not right for opportunity'
    when 4
      'Not UK registered'
    when 5
      'Not for third party'
    end
  end
end
