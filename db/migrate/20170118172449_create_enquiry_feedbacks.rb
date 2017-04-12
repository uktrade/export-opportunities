class CreateEnquiryFeedbacks < ActiveRecord::Migration
  def change
    create_table :enquiry_feedbacks do |t|
      t.integer :enquiry_id, foreign_key: true
      t.datetime :responded_at
      t.integer :initial_response, null: false, default: 0
      t.timestamps null: false
    end

    add_foreign_key :enquiry_feedbacks, :enquiries
    add_index :enquiry_feedbacks, :enquiry_id, unique: true
  end
end
