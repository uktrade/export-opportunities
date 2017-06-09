require 'rails_helper'

RSpec.describe EnquiryResponse do
  it { is_expected.to belong_to :enquiry }
  it { is_expected.to belong_to :editor }
end
