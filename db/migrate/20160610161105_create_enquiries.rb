class CreateEnquiries < ActiveRecord::Migration[4.2]
  def change
    create_table :enquiries do |t|
      t.references :opportunity, null: false

      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email_address, null: false
      t.string :company_telephone, null: false
      t.string :company_name, null: false
      t.string :company_address
      t.string :company_house_number
      t.string :company_postcode
      t.string :company_url
      t.string :existing_exporter, null: false
      t.string :company_sector, null: false
      t.text :company_explanation, null: false
      t.timestamps
    end
  end
end
