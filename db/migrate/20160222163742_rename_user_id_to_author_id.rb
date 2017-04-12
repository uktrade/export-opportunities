class RenameUserIdToAuthorId < ActiveRecord::Migration
  def change
    change_table :opportunities do |t|
      t.rename :user_id, :author_id
    end
  end
end
