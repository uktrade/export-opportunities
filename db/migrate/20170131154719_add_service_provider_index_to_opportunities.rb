class AddServiceProviderIndexToOpportunities < ActiveRecord::Migration[4.2]
  def change
    add_index :opportunities, :service_provider_id
  end
end
