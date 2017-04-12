class ReorderPostgresExtensions < ActiveRecord::Migration
  def up
    disable_extension 'uuid-ossp'
    disable_extension 'pg_stat_statements'
    disable_extension 'plpgsql'

    enable_extension 'plpgsql'
    enable_extension 'pg_stat_statements'
    enable_extension 'uuid-ossp'

    # Necessary setup to re-enable UUID
    change_table 'opportunities' do |t|
      t.change_default :id, 'uuid_generate_v4()'
    end

    change_table 'subscriptions' do |t|
      t.change_default :id, 'uuid_generate_v4()'
    end
  end

  def down
    # NO OP
  end
end
