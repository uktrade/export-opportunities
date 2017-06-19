class ReportCalculator
  ReportMonthly = ImmutableStruct.new(:opportunities_submitted, :opportunities_published, :enquiries, :enquiry_responses, :average_age_when_published)

  def call(stats_calculator)

  end
end