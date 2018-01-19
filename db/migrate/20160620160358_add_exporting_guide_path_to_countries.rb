class AddExportingGuidePathToCountries < ActiveRecord::Migration[4.2]
  def change
    add_column :countries, :exporting_guide_path, :string
  end
end
