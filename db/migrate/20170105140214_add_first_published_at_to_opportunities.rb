class AddFirstPublishedAtToOpportunities < ActiveRecord::Migration
  def change
    add_column :opportunities, :first_published_at, :timestamp
  end
end
