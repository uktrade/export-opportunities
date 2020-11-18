class CreateSubscriptionCpvs < ActiveRecord::Migration[5.2]
  def change
    create_table :subscription_cpvs do |t|
      t.references :subscription, foreign_key: true, type: :uuid
      t.string :industry_id

      t.timestamps
    end
  end
end
