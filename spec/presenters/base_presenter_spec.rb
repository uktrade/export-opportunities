# coding: utf-8

require 'rails_helper'

RSpec.describe BasePresenter do
  describe '#initialize' do
    it 'creates an instance' do
      presenter = BasePresenter.new
      expect(presenter).to be_truthy
    end
  end

  describe '#put' do
    it 'returns value when present' do
      presenter = BasePresenter.new

      expect(presenter.put('some present text')).to eq('some present text')
    end

    it 'returns default when value not present' do
      presenter = BasePresenter.new

      expect(presenter.put('')).to eq('none')
    end

    it 'returns specified default when value not present' do
      presenter = BasePresenter.new

      expect(presenter.put('', 'something else')).to eq('something else')
    end
  end

  # Private methods

  describe '::h' do
    it 'returns (access to) application helpers' do
      presenter = BasePresenter.new
      h = presenter.send(:h)
      link = h.link_to('UK Government', 'gov.uk')

      expect(has_html?(link)).to be_truthy
      expect(link).to include('href=')
      expect(link).to include('gov.uk')
      expect(link).to include('UK Government')
    end
  end

  # Helpers

  def has_html?(str)
    /\<\/\w+\>/.match(str)
  end
end
