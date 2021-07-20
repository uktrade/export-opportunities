# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cn2019 do
  it 'returns only the keys we want' do
    require 'set'

    cn2019 = create(:cn2019)

    returned = cn2019.as_indexed_json

    permitted_keys = Set.new %w[
      order level code parent code2 parent2 description english_text
      parent_description
    ]
    returned_keys = Set.new(returned.keys)

    expect(permitted_keys).to eq returned_keys
  end
end
