require 'rails_helper'

describe ApplicationHelper do
  describe '#present_html_or_formatted_text' do
    it 'returns an empty string if there is no text present' do
      result = present_html_or_formatted_text(nil)
      expect(result).to eq('')
    end

    it 'wraps text in paragraphs if no HTML tags present' do
      input = "Hello.\n\nWorld."
      result = present_html_or_formatted_text(input)
      expect(result).to eq("<p>Hello.</p>\n\n<p>World.</p>")
    end

    it 'intersperses break tags if no HTML tags present' do
      input = "Hello.\nWorld."
      result = present_html_or_formatted_text(input)
      expect(result).to eq("<p>Hello.\n<br />World.</p>")
    end

    it 'removes bad HTML if present' do
      input = 'Evil.<script></script>'
      result = present_html_or_formatted_text(input)
      expect(result).to eq('Evil.')
    end

    it 'leaves acceptable HTML if present' do
      input = 'Not <i>so</i> evil.<script></script>'
      result = present_html_or_formatted_text(input)
      expect(result).to eq('Not <i>so</i> evil.')
    end

    it 'wraps text in paragraphs if there are unencoded entities but no HTML tags' do
      input = 'Hello & World'
      result = present_html_or_formatted_text(input)
      expect(result).to eq('<p>Hello &amp; World</p>')
    end

    it 'does not wrap text in paragraphs if there are unencoded entities and HTML tags' do
      input = 'Hello & <em>World</em>'
      result = present_html_or_formatted_text(input)
      expect(result).to eq('Hello &amp; <em>World</em>')
    end

    it 'wraps text in paragraphs when apostrophes are present' do
      input = "Who'se misusin' apostrophe's?"
      result = present_html_or_formatted_text(input)
      expect(result).to eq("<p>Who'se misusin' apostrophe's?</p>")
    end
  end

  describe '#companies house' do
    it 'returns nil for nil company house number' do
      result = companies_house_url(nil)
      expect(result).to eq(nil)
    end

    # This test requires internet connection to Trade Profile API
    it 'returns trade profile for a company house number that we know exists in Companies House' do
      result = companies_house_url('SC406536')
      expect(result).to_not be(nil)
      expect(result).to include('SC406536')
    end

    it 'returns nil for a company house number that we know does not exist (invalid format) in Companies House' do
      result = companies_house_url('SC40 6536')
      expect(result).to eq(nil)
    end
  end

  describe '#trade profile' do
    it 'returns nil for nil company house number' do
      result = trade_profile(nil)
      expect(result).to eq(nil)
    end

    # This test requires internet connection to Trade Profile API
    it 'returns trade profile for a company house number that we know exists in Profile Staging' do
      skip('TODO: reintroduce once FAS adds data in their staging env')
      result = trade_profile('SC406536')
      expect(result).to_not eq(nil)
      expect(result).to include('SC406536')
    end

    it 'returns nil for a company house number that we know does not exist in Profile Staging' do
      result = trade_profile('00122306')
      expect(result).to eq(nil)
    end
  end
end
