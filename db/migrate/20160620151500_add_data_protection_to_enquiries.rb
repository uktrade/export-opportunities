class AddDataProtectionToEnquiries < ActiveRecord::Migration
  def change
    add_column :enquiries, :data_protection, :boolean, default: false
  end
end
