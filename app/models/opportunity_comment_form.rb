class OpportunityCommentForm
  include ActiveModel::Model

  attr_accessor :message
  validates :message, presence: true

  def initialize(opportunity:, author:)
    @opportunity = opportunity
    @author = author
  end

  def post!
    return false unless valid?

    OpportunityComment.create!(
      opportunity: @opportunity,
      author: @author,
      message: message
    )
  end
end
