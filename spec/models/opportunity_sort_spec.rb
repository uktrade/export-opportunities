require 'shared/shared_examples_for_sort_objects'

RSpec.describe OpportunitySort do
  it_behaves_like 'a sort object'

  it 'sets the provided column if it is valid' do
    sort = OpportunitySort.new(default_column: 'created_at', default_order: 'desc')
    sort.update(column: 'title', order: 'desc')
    expect(sort.column).to eq 'title'
  end
end
