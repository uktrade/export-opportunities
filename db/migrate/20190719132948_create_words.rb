class CreateWords < ActiveRecord::Migration[5.2]
  def change
    create_table :words do |t|
      t.string :text
      t.boolean :capitalize
      t.boolean :uppercase

      t.timestamps
    end
  end
end
