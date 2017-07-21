require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe DraftStatusMailer, type: :mailer do
  describe '.draft_status' do
    it 'sends a draft status notification to the editor creating the opportunity' do
      opportunity = create(:opportunity)
      editor = create(:editor)

      DraftStatusMailer.draft_status(opportunity, editor).deliver_later!

      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql("Action Needed: Your opportunity #{opportunity.title} has been sent to Draft")
      expect(last_delivery.body.encoded).to include('Your opportunity has been set to draft. Please login to the admin centre and go here to edit your opportunity:')
      expect(last_delivery.body.encoded).to include(edit_admin_opportunity_path(opportunity))

      expect(last_delivery.to).to include(Editor.find(opportunity.author_id).email)
      expect(last_delivery.from).to include('notifications@export.great.gov.uk')
      expect(last_delivery.bcc).to include(editor.email)
    end
  end
end
