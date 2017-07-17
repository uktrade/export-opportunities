class EnquiryFeedbackMailerPreview < ActionMailer::Preview
  def request_feedback
    user = User.create(
       email: 'email@example.com'
    )
    enquiry = Enquiry.create(
      first_name: 'Bob',
      last_name: 'London',
      legacy_email_address: 'email@example.com',
      opportunity: Opportunity.last,
      company_telephone: '0818118181',
      company_name: 'River',
      company_house_number: '99',
      company_address: '1 London',
      company_postcode: '1UW 1SO',
      company_url: 'river.com',
      existing_exporter: 'No',
      company_sector: Sector.first.slug,
      company_explanation: 'We can create rivers wherever we like',
      user_id: user.id
    )

    enquiry_feedback = enquiry.create_feedback
    EnquiryFeedbackMailer.request_feedback(enquiry_feedback)
  end
end
