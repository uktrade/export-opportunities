class CreateDocumentUrlMappers < ActiveRecord::Migration[4.2]
  def change
    create_table :document_url_mappers do |t|
      t.references :user, null: false
      t.references :enquiry, null: false
      t.string :original_filename, null: false
      t.string :hashed_id, null: false
      t.string :s3_link, null: false
      t.timestamps
    end
  end
end
