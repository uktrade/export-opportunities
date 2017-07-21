class DraftStatusSender
  def call(opportunity, editor)
    DraftStatusMailer.draft_status(opportunity, editor).deliver_later!
  end
end
