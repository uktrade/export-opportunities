class AddPartnerToServiceProvider < ActiveRecord::Migration[5.2]
  def change
    add_column :service_providers, :partner, :string
  end
end
