class GenerateStubUsers < ActiveRecord::Migration[4.2]
  def up
    sql = <<-SQL
     (
       SELECT DISTINCT email_address AS email FROM enquiries
        UNION SELECT DISTINCT email FROM subscriptions
     )
     EXCEPT SELECT email FROM users
    SQL

    emails = ActiveRecord::Base.connection.select_values(sql)

    puts "Generating #{emails.size} stub users"

    emails.each do |email|
      User.create!(email: email.downcase, uid: nil, provider: nil)
    end
  end

  def down
    User.where(uid: nil, provider: nil).delete_all
  end
end
