class AddPgpsqlExtension < ActiveRecord::Migration
  def change
    enable_extension 'plpgsql'
  end
end
