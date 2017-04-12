class AddServiceProviderIndexToOpportunities < ActiveRecord::Migration
  def change
    add_index :opportunities, :service_provider_id
  end
end
