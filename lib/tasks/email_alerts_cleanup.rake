# simple ruby script to process a CSV file with the following format:
# email
# and update our database
require 'csv'

namespace :reports do
  desc 'Unsubscribe users from database'
  task email_alerts_cleanup: :environment do
    arr_file = CSV.parse(open(Figaro.env.UNSUBSCRIBE_EMAILS_URL))
    arr_file.each_with_index do |data, line|
      next if line.zero?

      puts 'next email to unsuscribe:'
      email = data[0]
      puts email
      user = User.where(email: email).first
      next unless user&.id
      matched_subscriptions = Subscription.where(user_id: user.id)

      matched_subscriptions.each do |matched_subscription|
        puts ">> #{user.id} : #{matched_subscription&.id} <<"
        puts ">> #{user.id} : #{matched_subscription&.created_at} <<"
        puts ">> #{user.id} : #{matched_subscription&.unsubscribed_at} <<"

        next if matched_subscription.unsubscribed_at

        matched_subscription.unsubscribed_at = Time.zone.now
        matched_subscription.unsubscribe_reason = 5
        matched_subscription.save!
      end
    end
  end

  desc 'Add users to impact email blacklist'
  task impact_email_alerts_cleanup: :environment do
    arr_file = CSV.parse(open(Figaro.env.UNSUBSCRIBE_IMPACT_EMAILS_URL))
    arr_file.each_with_index do |data, line|
      next if line.zero?

      puts 'next impact email to add to the blacklist:'
      email = data[0]
      puts email
      user = User.where(email: email).first
      next unless user&.id
      FeedbackOptOut.new(user_id: user.id).save!
    end
  end
end
