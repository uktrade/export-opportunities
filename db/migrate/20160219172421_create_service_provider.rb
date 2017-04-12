class CreateServiceProvider < ActiveRecord::Migration
  def change
    create_table :service_providers do |t|
      t.string :name, null: false
    end
  end
end
