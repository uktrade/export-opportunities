# app/models/paper_trail/version.rb
module PaperTrail
  class Version < ApplicationRecord
    include PaperTrail::VersionConcern
    self.abstract_class = true
  end
end
