class AddUnsubscriptionTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :unsubscription_token, :string

    # Add check to make migration reversible
    if User.column_names.include? 'unsubscription_token'
	    User.find_each { |u| u.update_column(:unsubscription_token, (0...20).map { (65 + rand(26)).chr }.join) }
    end
  end
end
