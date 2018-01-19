class AddUuidExtension < ActiveRecord::Migration[4.2]
  def up
    enable_extension 'uuid-ossp'
    change_table 'opportunities' do |t|
      t.change_default :id, 'uuid_generate_v4()'
    end

    change_table 'subscriptions' do |t|
      t.change_default :id, 'uuid_generate_v4()'
    end
  end

  def down
    disable_extension 'uuid-ossp'
  end
end
