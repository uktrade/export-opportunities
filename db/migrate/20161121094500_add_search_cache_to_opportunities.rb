class AddSearchCacheToOpportunities < ActiveRecord::Migration[4.2]
  def change
    add_column :opportunities, :tsv, :tsvector
    add_index :opportunities, :tsv, using: 'gin'
  end
end
