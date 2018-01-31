class AddPgpsqlExtension < ActiveRecord::Migration[4.2]
  def change
    enable_extension 'plpgsql'
  end
end
