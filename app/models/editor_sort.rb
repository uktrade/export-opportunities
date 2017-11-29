class EditorSort
  attr_reader :column, :order
  VALID_SORT_COLUMNS = %w[name email role confirmed_at last_sign_in_at service_provider_name].freeze
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
