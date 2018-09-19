class OpportunitySort
  attr_reader :column, :order
  VALID_SORT_COLUMNS = %w[title status service_provider_name enquiries_count created_at original_language source first_published_at response_due_on ragg].freeze
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
