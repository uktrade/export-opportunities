class BackfillUuidOnUsers < ActiveRecord::Migration
  def up
    sql = 'UPDATE users SET uuid = uuid_generate_v4();'
    ActiveRecord::Base.connection.execute(sql)
  end

  def down
    # NO OP
  end
end
