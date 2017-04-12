class Admin::OpportunityCommentsController < Admin::BaseController
  def create
    opportunity = Opportunity.find(params[:opportunity_id])
    authorize opportunity

    comment_form = OpportunityCommentForm.new(opportunity: opportunity, author: current_editor)
    comment_form.message = comment_params[:message]

    if comment_form.post!
      redirect_to :back, notice: 'Your comment has been posted.'
    else
      redirect_to :back, alert: "Your comment could not be saved. #{comment_form.errors.full_messages.to_sentence}"
    end
  end

  private

  def comment_params
    params.require(:opportunity_comment_form).permit(:message)
  end
end
