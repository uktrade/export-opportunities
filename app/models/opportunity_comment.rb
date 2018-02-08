class OpportunityComment < ApplicationRecord
  belongs_to :author, class_name: 'Editor'
  belongs_to :opportunity

  delegate :name, to: :author, prefix: true, allow_nil: true

  validates :message, presence: true

  def posted_by_author?
    author == opportunity.author
  end
end
