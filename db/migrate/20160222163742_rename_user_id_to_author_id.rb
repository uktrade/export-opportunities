class RenameUserIdToAuthorId < ActiveRecord::Migration[4.2]
  def change
    change_table :opportunities do |t|
      t.rename :user_id, :author_id
    end
  end
end
