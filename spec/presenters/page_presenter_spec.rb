# coding: utf-8

require 'rails_helper'

RSpec.describe PagePresenter do
  describe '#initialize' do
    it 'initialises a presenter' do
      content = { some: 'content' }
      presenter = PagePresenter.new(content)

      expect(presenter.breadcrumbs).to_not be_nil
    end
  end

  describe '#content' do
    it 'returns content from first-level key' do
      content = { hello: 'Hello snoopy' }.with_indifferent_access
      presenter = PagePresenter.new(content)

      expect(presenter.content('hello')).to eq('Hello snoopy')
    end

    it 'returns content from nested-level key' do
      content = { hello: { message: { everyone: 'Hello everyone' } } }.with_indifferent_access
      presenter = PagePresenter.new(content)

      expect(presenter.content('hello.message.everyone')).to eq('Hello everyone')
    end

    it 'returns a blank string when key is not found' do
      content = { hello: { message: { everyone: 'Hello everyone' } } }.with_indifferent_access
      presenter = PagePresenter.new(content)

      expect(presenter.content('foo')).to eq('')
      expect(presenter.content('foo.bar')).to eq('')
      expect(presenter.content('foo.bar.widget')).to eq('')
    end
  end

  describe '#content_with_inclusion' do
    it 'returns content string with injected values' do
      content = { hello: 'Hello [$first_name] [$last_name]' }.with_indifferent_access
      presenter = PagePresenter.new(content)

      expect(presenter.content_with_inclusion('hello', %w[Darth Vader])).to eql('Hello Darth Vader')
      expect(presenter.content_with_inclusion('hello', ['Darth'])).to eql('Hello Darth [$last_name]')
      expect(presenter.content_with_inclusion('hello', ['', 'Vader'])).to eql('Hello Vader')
      expect(presenter.content_with_inclusion('hello', ['Darth', 'Vader', ' or shall we say, Anakin'])).to eql('Hello Darth Vader')
    end
  end

  describe '#content_without_inclusion' do
    it 'returns content string without injection markers' do
      content = { hello: 'Hello [$first_name] [$last_name]' }.with_indifferent_access
      presenter = PagePresenter.new(content)

      expect(presenter.content_without_inclusion('hello')).to eql('Hello ')
    end
  end

  describe '#create_trade_profile_url' do
    it 'returns the correct url depending on passed number' do
      content = { fields: { countries: {}, industries: {}, regions: {} } }
      presenter = PagePresenter.new(content)

      expect(presenter.create_trade_profile_url).to eql(Figaro.env.TRADE_PROFILE_CREATE_WITHOUT_NUMBER)
      expect(presenter.create_trade_profile_url('12345')).to eql("#{Figaro.env.TRADE_PROFILE_CREATE_WITH_NUMBER}12345")
    end
  end

  describe '#add_breadcrumb_current' do
    it 'adds a current page item' do
      content = { some: 'content' }
      presenter = PagePresenter.new(content)
      presenter.add_breadcrumb_current('foo')

      expect(presenter.breadcrumbs).to include(title: 'foo', slug: '')
    end
  end

  describe '#highlight_words' do
    it 'returns input content with target words surround in SPAN.highlight markup' do
      presenter = PagePresenter.new({})
      highlighted = presenter.highlight_words('foo bar diddle woo and more', %w[bar woo])

      expect(highlighted).to eq('foo <span class="highlight">bar</span> diddle <span class="highlight">woo</span> and more')
    end

    it 'returns unchanged input content when no target words found' do
      presenter = PagePresenter.new({})
      highlighted = presenter.highlight_words('foo bar diddle', %w[beer wine])

      expect(highlighted).to eq('foo bar diddle')
    end
  end
end
