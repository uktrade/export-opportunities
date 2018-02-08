class RemoveUuid < ActiveRecord::Migration[4.2]
  def up
    disable_extension 'uuid-ossp'
  end

  def down
    enable_extension 'uuid-ossp'
  end
end
