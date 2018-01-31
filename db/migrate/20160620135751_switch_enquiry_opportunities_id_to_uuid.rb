class SwitchEnquiryOpportunitiesIdToUuid < ActiveRecord::Migration[4.2]
  def up
    raise 'Enquiries table should be empty before migrating.' if Enquiry.any?

    change_table :enquiries do |t|
      t.remove :opportunity_id
      t.uuid :opportunity_id, default: 'uuid_generate_v4()', null: false
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
