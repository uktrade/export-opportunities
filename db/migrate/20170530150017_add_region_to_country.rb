class AddRegionToCountry < ActiveRecord::Migration[4.2]
  def change
    add_reference :countries, :region, index: true
  end
end
