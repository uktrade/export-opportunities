class RenameSearchToSearchTermOnSubscriptions < ActiveRecord::Migration
  def change
    rename_column :subscriptions, :search, :search_term
  end
end
