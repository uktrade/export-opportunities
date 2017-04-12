class AddNotNullAndForeignKeyToSubscriptionsAndEnquiries < ActiveRecord::Migration
  def change
    change_column_null :subscriptions, :user_id, false
    add_foreign_key :subscriptions, :users

    change_column_null :enquiries, :user_id, false
    add_foreign_key :enquiries, :users
  end
end
