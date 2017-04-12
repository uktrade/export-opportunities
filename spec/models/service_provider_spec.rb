require 'rails_helper'

RSpec.describe ServiceProvider do
  it { is_expected.to have_many :editors }
end
