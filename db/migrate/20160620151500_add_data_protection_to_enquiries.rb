class AddDataProtectionToEnquiries < ActiveRecord::Migration[4.2]
  def change
    add_column :enquiries, :data_protection, :boolean, default: false
  end
end
