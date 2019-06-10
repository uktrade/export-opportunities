class EnquirySort
  attr_reader :column, :order
  VALID_SORT_COLUMNS = %w[id company_name opportunity created_at].freeze # enquiry_response opportunity
  VALID_SORT_ORDERS = %w[desc asc].freeze

  def initialize(default_column:, default_order:)
    @column = default_column
    @order = default_order
  end

  def update(column:, order:)
    @column = VALID_SORT_COLUMNS.include?(column) ? column : @column
    @order = VALID_SORT_ORDERS.include?(order) ? order : @order
    self
  end
end
