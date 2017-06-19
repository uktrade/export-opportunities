class Reports < SimpleDelegator
  include ActionView::Helpers::TextHelper
  validates :country, :months, presence: true
end
