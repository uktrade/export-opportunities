class AddTargetsToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :published_target, :integer, default: 0
    add_column :countries, :responses_target, :integer, default: 0
  end
end
