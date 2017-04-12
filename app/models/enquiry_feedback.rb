class EnquiryFeedback < ActiveRecord::Base
  belongs_to :enquiry
  enum initial_response: {
    no_response: 0,
    won: 1,
    did_not_win: 2,
    cannot_remember: 3,
    never_heard_back: 4,
  }
end
