namespace :elasticsearch do
  desc 'Import all opportunities into ElasticSearch, deleting and recreating the index'
  task import_opportunities: :environment do
    # we need all opportunities or else pending opps won't get into the index and can never get published
    opportunities = Opportunity.all

    if Opportunity.__elasticsearch__.client.indices.exists? index: Opportunity.index_name
      print 'deleting index:', Opportunity.index_name, '...'
      Opportunity.__elasticsearch__.delete_index!
    end
    Opportunity.__elasticsearch__.create_index!

    print "Rebuilding index for #{opportunities.count} opportunities"

    opportunities.find_in_batches(batch_size: 5000) do |group|
      print '.'

      group.each do |opp|
        opp.__elasticsearch__.index_document refresh: true
      end
    end

    puts
  end

  desc 'Import all subscriptions into ElasticSearch, deleting and recreating the index'
  task import_subscriptions: :environment do
    subscriptions = Subscription.all

    if Subscription.__elasticsearch__.client.indices.exists? index: Subscription.index_name
      print 'deleting index:', Subscription.index_name, '...'
      Subscription.__elasticsearch__.delete_index!
    end
    Subscription.__elasticsearch__.create_index!

    print "Rebuilding index for #{subscriptions.count} opportunities"

    subscriptions.find_in_batches(batch_size: 100) do |group|
      print '.'

      group.each do |sub|
        sub.__elasticsearch__.update_document
      end
    end

    puts
  end

  desc 'Import all subscription notifications into ElasticSearch, deleting and recreating the index'
  task import_subscription_notifications: :environment do
    subscription_notifications = SubscriptionNotification.all

    if SubscriptionNotification.__elasticsearch__.client.indices.exists? index: SubscriptionNotification.index_name
      SubscriptionNotification.__elasticsearch__.delete_index!
      print 'deleting index:', SubscriptionNotification.index_name, '...'
    end
    SubscriptionNotification.__elasticsearch__.create_index!

    print "Rebuilding index for #{subscription_notifications.count} opportunities"

    subscription_notifications.find_in_batches(batch_size: 100) do |group|
      print '.'

      group.each do |subnot|
        subnot.__elasticsearch__.update_document
      end
    end

    puts
  end
end
