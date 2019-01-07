class EnquiryResponseLateMailerPreview < ActionMailer::Preview
  def first_reminder
    enquiry = Enquiry.first_or_create(
      user: User.last,
      first_name: 'Elijah',
      last_name: 'Little',
      company_telephone: '1-115-334-4358',
      company_name: 'ilpert, Sanford and Abbott',
      company_address: '813 Reinger Dale',
      company_house_number: '1027',
      company_postcode: '55939-3068',
      existing_exporter: 'Not yet',
      company_sector: 'human resources',
      company_explanation: 'Business-focused bifurcated budgetary management',
      opportunity: Opportunity.last
    )

    EnquiryResponseLateMailer.first_reminder(enquiry)
  end
end
