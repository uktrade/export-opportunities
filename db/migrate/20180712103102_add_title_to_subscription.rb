class AddTitleToSubscription < ActiveRecord::Migration[5.1]
  def change
    add_column :subscriptions, :title, :text
  end
end
