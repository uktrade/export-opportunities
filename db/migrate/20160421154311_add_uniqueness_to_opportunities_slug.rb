class AddUniquenessToOpportunitiesSlug < ActiveRecord::Migration
  def change
    change_column :opportunities, :slug, :string, null: true
    Opportunity.where(slug: '').update_all(slug: nil)
    add_index :opportunities, :slug, unique: true
  end
end
