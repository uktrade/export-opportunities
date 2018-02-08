class AddUnSubscribeReasonToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :unsubscribe_reason, :int
  end
end
