class AddTargetsToCountries < ActiveRecord::Migration[4.2]
  def change
    add_column :countries, :published_target, :integer, default: nil
    add_column :countries, :responses_target, :integer, default: nil
  end
end
