class EnquiryFeedback < ApplicationRecord
  belongs_to :enquiry
  enum initial_response: {
    won: 0,
    did_not_win: 1,
    dont_know_outcome: 2,
    dontknow_want_to_say: 3,
    no_response: 4,
  }
end