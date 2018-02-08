class RemoveWordpressId < ActiveRecord::Migration[4.2]
  def up
    remove_column :countries, :wordpress_id
    remove_column :sectors, :wordpress_id
    remove_column :types, :wordpress_id
    remove_column :values, :wordpress_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
