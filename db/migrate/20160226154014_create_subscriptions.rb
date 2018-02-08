class CreateSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :subscriptions do |t|
      t.string :email, null: false
      t.string :search
      t.timestamps
    end
  end
end
