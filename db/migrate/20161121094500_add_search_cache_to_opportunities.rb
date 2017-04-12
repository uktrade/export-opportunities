class AddSearchCacheToOpportunities < ActiveRecord::Migration
  def change
    add_column :opportunities, :tsv, :tsvector
    add_index :opportunities, :tsv, using: 'gin'
  end
end
