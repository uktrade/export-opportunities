class OpportunityCpv < ApplicationRecord
  belongs_to :opportunity

  after_commit on: %i[create update destroy] do
    opportunity.__elasticsearch__.index_document
  end
end
