class AddExportingGuidePathToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :exporting_guide_path, :string
  end
end
