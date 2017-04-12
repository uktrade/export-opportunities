class ReplaceOpportunitiesPrimaryKeyWithUuid < ActiveRecord::Migration
  def change
    drop_table :opportunities
    drop_table :contacts
    drop_table :countries_opportunities
    drop_table :opportunities_sectors
    drop_table :opportunities_types
    drop_table :opportunities_values

    create_table :opportunities, id: :uuid do |t|
      t.integer :wordpress_id, null: false
      t.string :title
      t.string :slug
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :status, null: false
      t.text :teaser
      t.date :response_due_on
      t.text :description
      t.integer :service_provider_id
      t.integer :author_id, null: false
    end

    create_table :contacts do |t|
      t.uuid :opportunity_id, null: false
      t.string :name, null: false
      t.string :email, null: false
    end

    create_table :countries_opportunities, id: false do |t|
      t.references :country, index: true, null: false
      t.uuid :opportunity_id, index: true, null: false
    end

    create_table :opportunities_sectors, id: false do |t|
      t.uuid :opportunity_id, index: true, null: false
      t.references :sector, index: true, null: false
    end

    create_table :opportunities_types, id: false do |t|
      t.uuid :opportunity_id, index: true, null: false
      t.references :type, index: true, null: false
    end

    create_table :opportunities_values, id: false do |t|
      t.uuid :opportunity_id, index: true, null: false
      t.references :value, index: true, null: false
    end
  end
end
