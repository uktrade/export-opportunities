class AddCountriesSectorsTypesAndValuesToSubscriptions < ActiveRecord::Migration
  def change
    create_table :countries_subscriptions, id: false do |t|
      t.references :country, index: true, null: false
      t.references :subscription, index: true, null: false
    end

    create_table :sectors_subscriptions, id: false do |t|
      t.references :sector, index: true, null: false
      t.references :subscription, index: true, null: false
    end

    create_table :subscriptions_types, id: false do |t|
      t.references :subscription, index: true, null: false
      t.references :type, index: true, null: false
    end

    create_table :subscriptions_values, id: false do |t|
      t.references :subscription, index: true, null: false
      t.references :value, index: true, null: false
    end
  end
end
