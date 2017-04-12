require 'shared/shared_examples_for_sort_objects'

RSpec.describe EditorSort do
  it_behaves_like 'a sort object'

  it 'sets the provided column if it is valid' do
    sort = EditorSort.new(default_column: 'created_at', default_order: 'desc')
    sort.update(column: 'name', order: anything)
    expect(sort.column).to eq 'name'
  end
end
