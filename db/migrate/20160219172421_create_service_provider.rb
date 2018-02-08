class CreateServiceProvider < ActiveRecord::Migration[4.2]
  def change
    create_table :service_providers do |t|
      t.string :name, null: false
    end
  end
end
