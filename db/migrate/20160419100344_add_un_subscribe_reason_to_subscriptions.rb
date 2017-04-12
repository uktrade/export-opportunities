class AddUnSubscribeReasonToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :unsubscribe_reason, :int
  end
end
