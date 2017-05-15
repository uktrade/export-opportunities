class CreateEnquiryResponses < ActiveRecord::Migration
  def change
    create_table :enquiry_responses do |t|
      t.integer :editor_id, foreign_key: true
      t.text :email_body
      t.integer :response_template_id
      t.timestamps null: false
    end
  end
end
