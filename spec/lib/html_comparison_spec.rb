require 'rails_helper'

RSpec.describe HTMLComparison do
  describe '#tags?' do
    it 'should return false for text that needs sanitisation' do
      result = HTMLComparison.new.tags?("<b>Bold</b> no more!  <a href='more.html'>See more here</a>...")
      expect(result).to eq false
    end

    it 'should return true for sanitised text' do
      result = HTMLComparison.new.tags?('Bold no more!See more here...')
      expect(result).to eq true
    end
  end
end