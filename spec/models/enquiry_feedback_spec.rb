require 'rails_helper'

RSpec.describe EnquiryFeedback do
  it { is_expected.to belong_to :enquiry }
  it { is_expected.to define_enum_for :initial_response }
end
