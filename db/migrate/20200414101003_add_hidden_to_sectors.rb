class AddHiddenToSectors < ActiveRecord::Migration[5.2]
  def change
    add_column :sectors, :hidden, :boolean
  end
end
