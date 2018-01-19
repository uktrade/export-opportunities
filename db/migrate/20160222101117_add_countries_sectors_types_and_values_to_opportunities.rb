class AddCountriesSectorsTypesAndValuesToOpportunities < ActiveRecord::Migration[4.2]
  def change
    create_table :countries_opportunities, id: false do |t|
      t.references :country, index: true, null: false
      t.references :opportunity, index: true, null: false
    end

    create_table :opportunities_sectors, id: false do |t|
      t.references :opportunity, index: true, null: false
      t.references :sector, index: true, null: false
    end

    create_table :opportunities_types, id: false do |t|
      t.references :opportunity, index: true, null: false
      t.references :type, index: true, null: false
    end

    create_table :opportunities_values, id: false do |t|
      t.references :opportunity, index: true, null: false
      t.references :value, index: true, null: false
    end
  end
end
