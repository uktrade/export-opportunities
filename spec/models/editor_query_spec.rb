require 'rails_helper'

RSpec.describe EditorQuery do
  describe '#editors' do
    it 'returns an editor query object' do
      editor = create(:editor, name: 'test editor')

      response = EditorQuery.new(sort: OpenStruct.new(column: 'created_at', order: 'desc')).editors

      expect(response).to be_kind_of(ActiveRecord::Relation)
      expect(response.first).to eq(editor)
    end

    context 'when a sort is provided' do
      it 'returns editors sorted in that order' do
        create(:editor, name: 'Abra')
        create(:editor, name: 'Bayleef')
        create(:editor, name: 'Charmander')

        sorter = OpenStruct.new(column: 'name', order: 'asc')
        result = EditorQuery.new(sort: sorter).editors
        expect(result[0].name).to eq('Abra')
        expect(result[1].name).to eq('Bayleef')
        expect(result[2].name).to eq('Charmander')
      end
    end
  end
end
