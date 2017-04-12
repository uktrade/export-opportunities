class CreateOpportunities < ActiveRecord::Migration
  def change
    create_table :opportunities do |t|
      t.integer :wordpress_id, null: false
      t.string :title
      t.string :slug
      t.timestamps null: false
      t.integer :status, null: false
      t.text :teaser
      t.date :response_due_on
      t.text :description
      t.references :service_provider
      t.references :user, null: false
    end
  end
end
