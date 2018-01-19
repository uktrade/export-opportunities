class AddEnquiriesCountToOpportunities < ActiveRecord::Migration[4.2]
  def change
    add_column :opportunities, :enquiries_count, :integer
    Opportunity.find_each { |opportunity| Opportunity.reset_counters(opportunity.id, :enquiries) }
  end
end
