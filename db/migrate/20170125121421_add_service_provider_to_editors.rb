class AddServiceProviderToEditors < ActiveRecord::Migration[4.2]
  def change
    add_reference :editors, :service_provider, index: true, foreign_key: true
  end
end
