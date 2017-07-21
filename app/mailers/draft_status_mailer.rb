class DraftStatusMailer < ApplicationMailer
  layout 'eig-email'

  def draft_status(opportunity, logged_in_user)
    editor_email = logged_in_user.email
    opportunity_author = Editor.find(opportunity.author_id)
    @opportunity_edit_path = edit_admin_opportunity_url(opportunity)

    mail from: 'notifications@export.great.gov.uk', name: 'Export opportunities', sender: 'noreply@export.great.gov.uk', to: opportunity_author.email, bcc: editor_email, subject: "Action Needed: Your opportunity #{opportunity.title} has been sent to Draft"
  end
end
