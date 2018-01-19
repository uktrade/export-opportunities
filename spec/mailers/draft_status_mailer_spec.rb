require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe DraftStatusMailer, type: :mailer do
  describe '.draft_status' do
    it 'sends a draft status notification to the editor creating the opportunity' do
      opportunity = create(:opportunity)
      editor = create(:editor)

      DraftStatusMailer.send_draft_status(opportunity, editor).deliver_now!

      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql('Returned to draft. Action required')
      expect(last_delivery.body.encoded).to include('The following opportunity cannot be published:')
      expect(last_delivery.body.encoded).to include(edit_admin_opportunity_path(opportunity))

      expect(last_delivery.to).to include(Editor.find(opportunity.author_id).email)
      expect(last_delivery.from).to include(Figaro.env.MAILER_FROM_ADDRESS!)
      expect(last_delivery.bcc).to include(editor.email)
    end
  end
end
