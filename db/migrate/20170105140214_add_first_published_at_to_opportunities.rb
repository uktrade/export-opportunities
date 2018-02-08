class AddFirstPublishedAtToOpportunities < ActiveRecord::Migration[4.2]
  def change
    add_column :opportunities, :first_published_at, :timestamp
  end
end
