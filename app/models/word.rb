class Word < ApplicationRecord
  before_save :set_lowercase

  def set_lowercase
    text.downcase!
  end
end
