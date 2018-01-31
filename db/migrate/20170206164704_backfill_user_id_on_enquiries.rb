class BackfillUserIdOnEnquiries < ActiveRecord::Migration[4.2]
  def up
    # Ensure we have the latest schema
    User.reset_column_information
    Enquiry.reset_column_information

    users_hash = User.pluck(:email, :id).to_h
    emails = Enquiry.select(:email_address).distinct.pluck(:email_address)

    emails.each do |email|
      Enquiry.where(email_address: email).update_all(user_id: users_hash[email.downcase])
    end

    change_column_null :enquiries, :email_address, true
    rename_column :enquiries, :email_address, :legacy_email_address
  end

  def down
    Enquiry.update_all(user_id: nil)

    rename_column :enquiries, :legacy_email_address, :email_address
    change_column_null :enquiries, :email_address, false
  end
end
