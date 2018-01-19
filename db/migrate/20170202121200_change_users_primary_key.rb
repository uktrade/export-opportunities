class ChangeUsersPrimaryKey < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.remove :id
      t.rename :uuid, :id
    end

    change_column_null :users, :id, false

    execute 'ALTER TABLE users ADD PRIMARY KEY (id);'
  end
end
