class AddEnquiriesCountToOpportunities < ActiveRecord::Migration
  def change
    add_column :opportunities, :enquiries_count, :integer
    Opportunity.find_each { |opportunity| Opportunity.reset_counters(opportunity.id, :enquiries) }
  end
end
