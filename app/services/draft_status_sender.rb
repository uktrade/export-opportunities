class DraftStatusSender
  def call(opportunity, editor)
    DraftStatusMailer.send_draft_status(opportunity, editor).deliver_later!
  end
end
