# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionSearchBuilder do
  describe '.new' do
    subject { SubscriptionSearchBuilder.new(args) }

    let(:attrs) do
      [subject.sectors, subject.countries, subject.types, subject.values]
    end

    context 'when called with no arguments' do
      let(:args) { {} }

      it 'initialises with default values' do
        expect(attrs).to all be_a(Array).and be_empty
      end
    end

    context 'when called with arguments' do
      let(:expected_values) { [[1], [2], [3], [4]] }

      context 'and the values are not collections' do
        let(:args) { { sectors: 1, countries: 2, types: 3, values: 4 } }

        it 'coerces them into arrays' do
          expect(attrs).to eql expected_values
        end
      end

      context 'and the values are collections' do
        let(:args) { { sectors: [1], countries: [2], types: [3], values: [4] } }

        it 'keeps the right types' do
          expect(attrs).to eql expected_values
        end
      end
    end
  end

  describe '#call' do
    subject { SubscriptionSearchBuilder.new(args).call }

    let(:expected_base_query) do
      {
        bool: {
          must: [
            { match_all: {} },
            { bool: { filter: { exists: { field: :confirmed_at } } } },
            { bool: { must_not: { exists: { field: :unsubscribed_at } } } }
          ]
        }
      }
    end

    context 'when called with no arguments' do
      let(:args) { {} }

      it 'returns the default search query with no parameters' do
        expect(subject[:search_query]).to eql expected_base_query
      end
    end

    context 'when called with sectors' do
      let(:args) { { sectors: [1, 2] } }

      it 'builds filters by sectors' do
        expected_filter = [
          { terms: { 'sectors.id': [1, 2] } },
          { bool: { must_not: { exists: { field: 'sectors.id' } } } }
        ]
        expect(subject[:search_query][:bool][:should]).to eql expected_filter
        expect(subject[:search_query][:bool][:minimum_should_match]).to eql 1
      end
    end

    context 'when called with countries' do
      let(:args) { { countries: [3, 4] } }

      it 'builds filters by countries' do
        expected_filter = [
          { terms: { 'countries.id': [3, 4] } },
          { bool: { must_not: { exists: { field: 'countries.id' } } } }
        ]
        expect(subject[:search_query][:bool][:should]).to eql expected_filter
        expect(subject[:search_query][:bool][:minimum_should_match]).to eql 1
      end
    end

    context 'when called with opportunity types' do
      let(:args) { { types: [5] } }

      it 'builds filters by opportunity types' do
        expected_filter = [
          { terms: { 'types.id': [5] } },
          { bool: { must_not: { exists: { field: 'types.id' } } } }
        ]
        expect(subject[:search_query][:bool][:should]).to eql expected_filter
        expect(subject[:search_query][:bool][:minimum_should_match]).to eql 1
      end
    end

    context 'when called with contract values' do
      let(:args) { { values: [6] } }

      it 'builds filters by contract values' do
        expected_filter = [
          { terms: { 'values.id': [6] } },
          { bool: { must_not: { exists: { field: 'values.id' } } } }
        ]
        expect(subject[:search_query][:bool][:should]).to eql expected_filter
        expect(subject[:search_query][:bool][:minimum_should_match]).to eql 1
      end
    end

    context 'when called with all filters' do
      let(:args) do
        { sectors: [1, 2], countries: [3, 4], types: [5], values: [6] }
      end

      it 'builds all the filters' do
        expected_filter = [
          { terms: { 'sectors.id': [1, 2] } },
          { bool: { must_not: { exists: { field: 'sectors.id' } } } },
          { terms: { 'countries.id': [3, 4] } },
          { bool: { must_not: { exists: { field: 'countries.id' } } } },
          { terms: { 'types.id': [5] } },
          { bool: { must_not: { exists: { field: 'types.id' } } } },
          { terms: { 'values.id': [6] } },
          { bool: { must_not: { exists: { field: 'values.id' } } } }
        ]
        expect(subject[:search_query][:bool][:should]).to eql expected_filter
        expect(subject[:search_query][:bool][:minimum_should_match]).to eql 4
      end
    end
  end
end
