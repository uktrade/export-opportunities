class RemovePlpgsqlExtension < ActiveRecord::Migration[4.2]
  def up
    # disable_extension 'plpgsql'
  end

  def down
    # enable_extension 'plpgsql'
  end
end
