class AddNewEnquiryFieldsToEnquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :enquiries, :job_title, :string
    add_column :enquiries, :trading_address, :string
    add_column :enquiries, :trading_address_postcode, :string
  end
end
