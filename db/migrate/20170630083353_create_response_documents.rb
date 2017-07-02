class CreateResponseDocuments < ActiveRecord::Migration
  def change
    create_table :response_documents do |t|
      t.belongs_to :enquiry_response, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
