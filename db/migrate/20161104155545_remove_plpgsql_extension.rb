class RemovePlpgsqlExtension < ActiveRecord::Migration
  def up
    disable_extension 'plpgsql'
  end

  def down
    enable_extension 'plpgsql'
  end
end
