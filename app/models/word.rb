class Word < ApplicationRecord

  before_save :set_lowercase

  def set_lowercase
    self.text.downcase!
  end

end
