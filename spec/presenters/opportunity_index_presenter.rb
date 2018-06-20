# coding: utf-8
require 'rails_helper'

RSpec.describe LandingPresenter do
  describe '#featured_industries' do
    it 'initializes a presenter' do
      content = { 'some': "content" }
      industries = Sector.where(id: [9, 31])
      presenter = LandingPresenter.new(content, industries)

      expect(presenter.breadcrumbs).to_not be_nil
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
