class EnquiryFeedback < ActiveRecord::Base
  belongs_to :enquiry
  enum initial_response: {
    dont_know_outcome: 0,
    did_not_win: 1,
    won: 2,
    no_response: 3,
    dontknow_want_to_say: 4,
  }
end
