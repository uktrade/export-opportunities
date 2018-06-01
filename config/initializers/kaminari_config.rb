Kaminari.configure do |config|
  config.default_per_page = 10
  # config.max_per_page = nil
  config.window = 3
  config.outer_window = 1
  config.max_pages = 100
  # config.left = 0
  # config.right = 0
  config.page_method_name = :page
  config.param_name = :paged
end
