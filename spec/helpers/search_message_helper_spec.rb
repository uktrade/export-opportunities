require 'rails_helper'

describe SearchMessageHelper do

  # -- helpers --

  def has_html?(message)
    %r{\<\/\w+\>|\<\w+\s+\w+=}.match(message)
  end

  def countries(slugs)
    countries = []
    slugs.each do |slug|
      country = Country.find_by(slug: slug)
      country = create(:country, name: to_words(slug), slug: slug) if country.nil?
      countries.push(country)
    end
    countries
  end

  def to_words(slug)
    arr = slug.split('-')
    arr.each_with_index { |word, index| arr[index] = word.capitalize }
    arr.join(' ')
  end

  # -------------

  before do
    create(:country, name: "Spain", slug: 'spain')
    create(:country, name: "Mexico", slug: 'mexico')
  end

  describe '#searched_for' do
    it 'Returns plain text message " for [search term]"' do
      expect(searched_for('food')).to eql(' for food')
    end

    it 'Returns HTML markup for message " for [search term]"' do
      message = searched_for('food', with_html: true)
      expect(message).to include('food')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns an empty string when searching without a specified term' do
      expect(searched_for('')).to eql('')
    end
  end

  describe '#searched_for_with_html' do
    it 'Returns HTML markup for message " for [search term]"' do
      message = searched_for('food', with_html: true)

      expect(message).to include(' for ')
      expect(message).to include('food')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns an empty string when searching without a specified term' do
      expect(searched_for('', with_html: true)).to eql('')
    end
  end

  describe '#searched_in' do
    it 'Returns plain text message " in [country]"' do
      params = { s: 'food', countries: %w[spain] }
      filter = SearchFilter.new(params)
      message = searched_in(filter, with_html: true)

      expect(searched_in(filter)).to eql(' in Spain')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns plain text message " in [country] or [country]"' do
      params = { s: 'food', countries: %w[spain mexico] }
      filter = SearchFilter.new(params)

      output = [' in Spain or Mexico', ' in Mexico or Spain']
      expect(output).to include(searched_in(filter))
      expect(has_html?(searched_in(filter, with_html: true))).to be_truthy
    end

    it 'Returns HTML markup for message " in [country]"' do
      params = { s: 'food', countries: %w[spain mexico] }
      filter = SearchFilter.new(params)
      message = searched_in(filter, with_html: true)

      expect(message).to include(' in ')
      expect(message).to include('Spain')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns HTML markup for message " in [country] or [country]"' do
      params = { s: 'food', countries: %w[spain mexico] }
      filter = SearchFilter.new(params)
      message = searched_in(filter, with_html: true)

      expect(message).to include(' in ')
      expect(message).to include('Spain')
      expect(message).to include(' or ')
      expect(message).to include('Mexico')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns empty string when no searching without regions or countries' do
      params = {}
      filter = SearchFilter.new(params)

      expect(searched_in(filter)).to eql('')
    end

    it 'Returns countries as a region name when a full set is matched' do
      slugs = %w[armenia azerbaijan georgia kazakhstan mongolia russia tajikistan turkey ukraine uzbekistan]
      countries(slugs)
      params = { s: 'food', countries: slugs }
      filter = SearchFilter.new(params)
      searched_in_without_matched_regions = searched_in(filter)
      names = searched_in_without_matched_regions.gsub(/\s+(or|in)\s+/, '|').split('|').drop(1) # first is empty

      # First run it with countries that won't match a full region
      expect(names.length).to eq(10)
      expect(names.join(' ')).to eq('Armenia Azerbaijan Georgia Kazakhstan Mongolia Russia Tajikistan Turkey Ukraine Uzbekistan')

      # Now add some countries that should match regions
      mediterranean_europe = %w[cyprus greece israel italy portugal spain]
      north_east_asia = %w[taiwan south-korea japan]
      countries(mediterranean_europe)
      countries(north_east_asia)
      params = { s: 'food', countries: slugs.concat(mediterranean_europe, north_east_asia) }
      filter = SearchFilter.new(params)
      searched_in_with_matched_regions = searched_in(filter)
      names = searched_in_with_matched_regions.gsub(/\s+(or|in)\s+/, '|').split('|').drop(1) # first is empty

      expect(names.length).to eq(12)
      expect(names.join(' ')).to eq('Mediterranean Europe North East Asia Armenia Azerbaijan Georgia Kazakhstan Mongolia Russia Tajikistan Turkey Ukraine Uzbekistan')
    end
  end

  describe '#searched_in_with_html' do
    it 'Returns HTML markup for message " in [country]"' do
      params = { s: 'food', countries: %w[spain] }
      filter = SearchFilter.new(params)
      message = searched_in(filter, with_html: true)

      expect(message).to include(' in ')
      expect(message).to include('Spain')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns HTML markup for message " in [country] or [country]"' do
      params = { s: 'food', countries: %w[spain mexico] }
      filter = SearchFilter.new(params)
      message = searched_in(filter, with_html: true)

      expect(message).to include(' in ')
      expect(message).to include('Spain')
      expect(message).to include(' or ')
      expect(message).to include('Mexico')
      expect(has_html?(message)).to be_truthy
    end
  end

  describe '#selected_filter_option_names' do
    it 'Return a string array of selected filter labels' do
      params = { countries: %w[spain mexico] }
      filter = SearchFilter.new(params)
      selected = selected_filter_option_names(filter)

      expect(selected).to eq(%w[Mexico Spain]).or eq(%w[Spain Mexico])
    end

    it 'Return an empty array when no filters selected' do
      params = {}
      filter = SearchFilter.new(params)
      selected = selected_filter_option_names(filter)

      expect(selected).to eql([])
    end
  end

end
