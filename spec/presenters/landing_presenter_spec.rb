# coding: utf-8
require 'rails_helper'

RSpec.describe LandingPresenter do
  describe '#initialize' do
    it 'initializes a presenter' do
      content = { 'some': "content" }
      industries = Sector.where(id: [9, 31])
      presenter = LandingPresenter.new(content, industries)

      expect(presenter.breadcrumbs).to_not be_nil
    end
  end

  describe '#title' do
    # Important! content is specified using '=>' syntax to mimic .yml file handling.
    it 'should return title without a count when no argument is received' do
      content = { 'title_without_count' => 'Search export opportunities' }
      presenter = LandingPresenter.new(content, [])

      # Extra space in string is intentional.
      expect(presenter.title).to eql('Search export opportunities')
    end

    it 'should return title without a count passed a number less than or equal to zero' do
      content = { 'title_without_count' => 'Search export opportunities' }
      presenter = LandingPresenter.new(content, [])
      total = 0

      expect(presenter.title(total)).to eql('Search export opportunities')
    end

    it 'should return title with count when passed a number greater than zero' do
      content = { 'title_with_count' => 'Search over [$include_count] export opportunities' }
      presenter = LandingPresenter.new(content, [])
      total = 100

      expect(presenter.title(total)).to eql('Search over 100 export opportunities')
    end
  end

  # TODO:fix - more tests required
  describe '#featured_industries' do
    it 'should return a list' do
      skip('Need to add some proper tests to keep presenter on track')
      content = { 'some': "content" }
      industries = Sector.where(id: [9, 31])
      presenter = LandingPresenter.new(content, industries)

      expect(presenter.featured_industries.length).to eq(2)
    end
  end
end
