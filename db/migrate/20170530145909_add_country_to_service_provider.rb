class AddCountryToServiceProvider < ActiveRecord::Migration
  def change
    add_reference :service_providers, :country, index: true
  end
end
