class Admin::OpportunityCommentsController < Admin::BaseController
  def create
    opportunity = Opportunity.find(params[:opportunity_id])
    authorize opportunity

    comment_form = OpportunityCommentForm.new(opportunity: opportunity, author: current_editor)
    comment_form.message = comment_params[:message]

    if comment_form.post!
      if params[:commit] == 'Return to draft with comment' && current_editor.role == 'administrator'
        DraftStatusSender.new.call(opportunity, current_editor)
        UpdateOpportunityStatus.new.call(opportunity, 'draft')
      end
      redirect_back(notice: 'Your comment has been posted.', fallback_location: '/')
    else
      redirect_back alert: "Your comment could not be saved. #{comment_form.errors.full_messages.to_sentence}", fallback_location: '/'
    end
  end

  private

  def comment_params
    params.require(:opportunity_comment_form).permit(:message, :opportunity)
  end
end
