# frozen_string_literal: true

# Cn2019
class Cn2019 < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  def as_indexed_json(_ = {})
    as_json(
      only: %i[
        order level code parent code2 parent2 description english_text parent_description
      ]
    )
  end
end
