require 'rails_helper'

RSpec.describe OpportunityComment do
  it { is_expected.to belong_to :opportunity }
  it { is_expected.to belong_to(:author).class_name('Editor') }
  it { is_expected.to validate_presence_of(:message) }

  describe '#posted_by_author?' do
    it 'is true when the comment was posted by the author of the opportunity' do
      uploader = create(:uploader)
      opportunity = create(:opportunity, author: uploader)
      comment = create(:opportunity_comment, opportunity: opportunity, author: uploader)

      expect(comment.posted_by_author?).to be true
    end

    it 'is false when the comment was not posted by the author of the opportunity' do
      other_editor = create(:editor)
      uploader = create(:uploader)

      opportunity = create(:opportunity, author: uploader)
      comment = create(:opportunity_comment, opportunity: opportunity, author: other_editor)

      expect(comment.posted_by_author?).to be false
    end
  end
end
