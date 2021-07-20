class CreateCn2019s < ActiveRecord::Migration[6.0]
  def change
    create_table :cn2019s do |t|
      t.string   :order,              null: false
      t.string   :level,              null: false
      t.string   :code,               null: false
      t.string   :parent
      t.string   :code2
      t.string   :parent2
      t.text     :description,        null: false
      t.text     :english_text
      t.text     :parent_description
    end
  end
end
