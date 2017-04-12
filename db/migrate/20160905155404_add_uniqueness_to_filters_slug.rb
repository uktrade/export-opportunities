class AddUniquenessToFiltersSlug < ActiveRecord::Migration
  def change
    add_index :countries, :slug, unique: true
    add_index :sectors, :slug, unique: true
    add_index :types, :slug, unique: true
    add_index :values, :slug, unique: true
  end
end
