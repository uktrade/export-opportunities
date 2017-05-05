class EnquiryFeedback < ActiveRecord::Base
  belongs_to :enquiry
  enum initial_response: {
    no_response: 0,
    won: 1,
    did_not_win: 2,
    dont_know_outcome: 3,
    never_heard_back: 4,
    cannot_remember: 5,
    dontknow_want_to_say: 6
  }
end
