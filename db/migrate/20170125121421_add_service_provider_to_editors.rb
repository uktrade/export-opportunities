class AddServiceProviderToEditors < ActiveRecord::Migration
  def change
    add_reference :editors, :service_provider, index: true, foreign_key: true
  end
end
