class CreateEnquiryResponses < ActiveRecord::Migration
  def change
    create_table :enquiry_responses do |t|
      t.belongs_to :editor, index: true, foreign_key: true
      t.references :enquiry, index: true
      t.text :email_body
      t.timestamps null: false
    end
    add_foreign_key :enquiry, :enquiry_responses
  end
end
