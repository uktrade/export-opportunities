require 'app/models/opportunity_sort'
require 'app/models/editor_sort'

RSpec.shared_examples 'a sort object' do
  let(:custom_sort_object) { described_class.new(default_column: 'created_at', default_order: 'desc') }

  describe '#initialize' do
    it 'sets the column and order to the provided defaults' do
      expect(custom_sort_object.column).to eq('created_at')
      expect(custom_sort_object.order).to eq('desc')
    end
  end

  describe '#update' do
    it 'sets the provided order if it is valid' do
      expect(custom_sort_object.update(column: anything, order: 'asc').order).to eq 'asc'
    end

    it 'sets default column if none is provided' do
      expect(custom_sort_object.update(column: nil, order: anything).column).to eq 'created_at'
    end

    it 'sets default order if none is provided' do
      expect(custom_sort_object.update(column: anything, order: nil).order).to eq 'desc'
    end

    it 'sets default column if an invalid one is provided' do
      expect(custom_sort_object.update(column: 'description', order: anything).column).to eq 'created_at'
    end

    it 'sets default order if an invalid one is provided' do
      expect(custom_sort_object.update(column: anything, order: 'sideways').order).to eq 'desc'
    end
  end
end
