class RenameSearchToSearchTermOnSubscriptions < ActiveRecord::Migration[4.2]
  def change
    rename_column :subscriptions, :search, :search_term
  end
end
