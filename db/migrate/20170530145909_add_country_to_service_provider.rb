class AddCountryToServiceProvider < ActiveRecord::Migration[4.2]
  def change
    add_reference :service_providers, :country, index: true
  end
end
