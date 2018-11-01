# coding: utf-8

require 'rails_helper'

RSpec.describe LandingPresenter do
  describe '#initialize' do
    it 'initializes a presenter' do
      create(:sector, slug: 'sector-1', name: 'sector one', id: 9)
      create(:sector, slug: 'sector-2', name: 'sector two', id: 31)
      presenter = LandingPresenter.new({}, Sector.where(id: [9, 31]))
      sector_list = presenter.instance_variable_get(:@sector_list)

      expect(sector_list.length).to eql(2)
    end
  end

  describe '#description' do
    # Important! content is specified using '=>' syntax to mimic .yml file handling.
    it 'should return description without injection markers when no argument is received' do
      content = { 'description' => 'Search [$count] export opportunities' }
      presenter = LandingPresenter.new(content, [])

      expect(presenter.description).to eql('Search export opportunities')
    end

    it 'should return description without injection markers when passed a number less than or equal to zero' do
      content = { 'description' => 'Search [$count] export opportunities' }
      presenter = LandingPresenter.new(content, [])

      expect(presenter.description(-1)).to eql('Search export opportunities')
      expect(presenter.description(0)).to eql('Search export opportunities')
    end

    it 'should return description with number when passed a number greater than zero' do
      content = { 'description' => 'Search [$count] export opportunities' }
      presenter = LandingPresenter.new(content, [])
      total = 100

      expect(presenter.description(total)).to include('Search ')
      expect(presenter.description(total)).to include(' export opportunities')
      expect(presenter.description(total)).to include('100')
    end

    it 'should return description with required HTML for number display' do
      content = { 'description' => 'Search [$count] export opportunities' }
      presenter = LandingPresenter.new(content, [])

      expect(presenter.description(100)).to eql('Search <span class="number">100</span> export opportunities')
    end

    it 'should return description with correctly formatted number' do
      content = { 'description' => 'Search [$count] export opportunities' }
      presenter = LandingPresenter.new(content, [])

      expect(presenter.description(100)).to include('100')
      expect(presenter.description(1_000)).to include('1,000')
      expect(presenter.description(100_000)).to include('100,000')
    end
  end

  describe '#featured_industries' do
    it 'should return a list of featured industries' do
      create(:sector, slug: 'sector-1', name: 'sector one', id: 9)
      create(:sector, slug: 'sector-2', name: 'sector two', id: 31)
      presenter = LandingPresenter.new({}, Sector.where(id: [9, 31]))

      expect(presenter.featured_industries.length).to eql(2)
      expect(presenter.featured_industries[0][:title]).to eql('sector one')
      expect(presenter.featured_industries[0][:url]).to eql('/opportunities?sectors[]=sector-1')
    end
  end
end
