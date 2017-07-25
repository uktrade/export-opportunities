class AddTargetsToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :published_target, :integer, default: nil
    add_column :countries, :responses_target, :integer, default: nil
  end
end
