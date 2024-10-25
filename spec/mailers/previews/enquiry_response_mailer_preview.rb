class EnquiryResponseMailerPreview < ActionMailer::Preview

  def reminder
    opportunity = Opportunity.last
    contact = Contact.first_or_create(
      name: 'Joe smith',
      email: 'joe@smith.com',
      opportunity: opportunity
    )
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
      opportunity: opportunity
    )
    EnquiryResponseMailer.reminder(enquiry)
  end
  
end
