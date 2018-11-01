# coding: utf-8

require 'rails_helper'

RSpec.describe HelpArticlePresenter do
  describe '#initialize' do
    it 'initializes a presenter' do
      help_article_presenter = HelpArticlePresenter.new('an_article_id', 'a_section_id')

      expect(help_article_presenter.article_id).to eq('an_article_id')
      expect(help_article_presenter.section_id).to eq('a_section_id')
    end
  end

  describe '#text_to_id' do
    it 'submits a valid text to id' do
      help_article_presenter = HelpArticlePresenter.new('url', 'some_section_id')
      text_to_id = help_article_presenter.text_to_id('Hooked on Monkey Fonics')

      expect(text_to_id).to eq 'hookedonmonkeyfonics'
    end

    it 'submits non latin text' do
      help_article_presenter = HelpArticlePresenter.new('url', 'some_section_id')
      text_to_id = help_article_presenter.text_to_id('出口很好')

      expect(text_to_id).to eq ''
    end
  end

  describe '#section' do
    it 'adds a section to the list' do
      help_article_presenter = HelpArticlePresenter.new('url', 'some_section_id')
      help_article_presenter.section('Kroxldyphivc', 'some_content')
      first_section = help_article_presenter.sections.first

      expect(first_section[:id]).to eq('kroxldyphivc')
      expect(first_section[:content]).to eq('some_content')
      expect(first_section[:url]).to eq('/admin/help/url/kroxldyphivc')
      expect(first_section[:current]).to eq false
    end

    it 'adds a **current** section to the list' do
      help_article_presenter = HelpArticlePresenter.new('url', 'chare')
      help_article_presenter.section('chare', 'some_content')
      first_section = help_article_presenter.sections.first

      expect(first_section[:id]).to eq('chare')
      expect(first_section[:content]).to eq('some_content')
      expect(first_section[:url]).to eq('/admin/help/url/chare')
      expect(first_section[:current]).to eq true
    end
  end

  describe '#pagination' do
    it 'returns correct prev and next links for guidance pagination when accessing the middle page' do
      help_article_presenter = HelpArticlePresenter.new('url', 'ronniedio')
      help_article_presenter.section('RebeccaSealfon', 1)
      help_article_presenter.section('RonnieDio', 2)
      help_article_presenter.section('RodStewart', 3)
      pagination_links = help_article_presenter.pagination

      expect(pagination_links[:previous][:id]).to eq 'rebeccasealfon'
      expect(pagination_links[:next][:id]).to eq 'rodstewart'
    end

    it 'returns correct prev and next links for guidance pagination when accessing the first page' do
      help_article_presenter = HelpArticlePresenter.new('url', 'rebeccasealfon')
      help_article_presenter.section('RebeccaSealfon', 1)
      help_article_presenter.section('RonnieDio', 2)
      help_article_presenter.section('RodStewart', 3)
      pagination_links = help_article_presenter.pagination

      expect(pagination_links[:previous]).to eq nil
      expect(pagination_links[:next][:id]).to eq 'ronniedio'
    end

    it 'returns correct prev and next links for guidance pagination when accessing the last page' do
      help_article_presenter = HelpArticlePresenter.new('url', 'rodstewart')
      help_article_presenter.section('RebeccaSealfon', 1)
      help_article_presenter.section('RonnieDio', 2)
      help_article_presenter.section('RodStewart', 3)
      pagination_links = help_article_presenter.pagination

      expect(pagination_links[:previous][:id]).to eq 'ronniedio'
      expect(pagination_links[:next]).to eq nil
    end

    it 'returns no prev or next links when only one section in the list' do
      help_article_presenter = HelpArticlePresenter.new('url', 'rodstewart')
      help_article_presenter.section('RebeccaSealfon', 1)
      pagination_links = help_article_presenter.pagination

      expect(pagination_links[:previous]).to eq nil
      expect(pagination_links[:next]).to eq nil
    end
  end
end
