class CreateEnquiryResponses < ActiveRecord::Migration
  def change
    create_table :enquiry_responses do |t|
      t.belongs_to :editor, index: true, foreign_key: true
      t.belongs_to :enquiry, index: true, foreign_key: true
      t.text :email_body
      t.timestamps null: false
    end
  end
end
