class RemoveUuid < ActiveRecord::Migration
  def up
    disable_extension 'uuid-ossp'
  end

  def down
    enable_extension 'uuid-ossp'
  end
end
