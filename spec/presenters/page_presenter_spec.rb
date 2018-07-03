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

  describe '#content_with_inclusion' do
    it 'injects values within a retrieved content string' do
      content = { some: 'something [$value1] here and [$value2]' }.with_indifferent_access
      presenter = PagePresenter.new(content)

      expect(presenter.content_with_inclusion('some', ['goes'])).to eql('something goes here and [$value2]')
      expect(presenter.content_with_inclusion('some', ['goes', 'there'])).to eql('something goes here and there')
      expect(presenter.content_with_inclusion('some', ['goes', 'there', 'not required'])).to eql('something goes here and there')
    end
  end

  describe '#create_trade_profile_url' do
    it 'returns the correct url depending on passed number' do
      content = { some: 'content' }
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

      expect(presenter.breadcrumbs).to include({title: "foo", slug: ""})
    end
  end
end
