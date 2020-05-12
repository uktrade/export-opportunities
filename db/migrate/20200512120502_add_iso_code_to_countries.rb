class AddIsoCodeToCountries < ActiveRecord::Migration[5.2]
  def change
    add_column :countries, :iso_code, :string
  end
end
