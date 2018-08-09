class AddOriginalLanguageToOpportunity < ActiveRecord::Migration[5.2]
  def change
    add_column :opportunities, :original_language, :integer, null: :false, default: 0
  end
end
