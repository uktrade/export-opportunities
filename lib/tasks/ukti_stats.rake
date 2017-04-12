desc 'Tasks to get stats from the data'
task ukti_stats: :environment do
  padding = 8
  pad_with = ' '
  puts <<-EOF
  Opportunities
  ------------------------------------------------------------------
  Total:            #{Opportunity.count.to_s.rjust(padding, pad_with)}
  Published:        #{Opportunity.publish.count.to_s.rjust(padding, pad_with)}
  Pending:          #{Opportunity.pending.count.to_s.rjust(padding, pad_with)}
  Expired:          #{Opportunity.expired.count.to_s.rjust(padding, pad_with)}
  Trash:            #{Opportunity.trash.count.to_s.rjust(padding, pad_with)}

  Subscriptions
  ------------------------------------------------------------------
  Total:            #{Subscription.count.to_s.rjust(padding, pad_with)}
  Confirmed:        #{Subscription.confirmed.active.count.to_s.rjust(padding, pad_with)}
  Unconfirmed:      #{Subscription.unconfirmed.active.count.to_s.rjust(padding, pad_with)}
  Unsubscribed:     #{Subscription.unsubscribed.count.to_s.rjust(padding, pad_with)}

  Explanation of Subscriptions
  ------------------------------------------------------------------
  Total          Absolute total number of subscriptions of all time,
                 irrespective of state.
  Confirmed      Subscriptions that will currently receive emails
                 about opportunities.
  Unconfirmed    Subscriptions that, once confirmation is complete,
                 will be able to receive emails about opportunities.
  Unsubscribed   Subscriptions who could once receive emails, but
                 have since opted out. These no longer receive
                 opportunities.
  ------------------------------------------------------------------

  EOF
end

desc 'Tasks to get stats from the data since a given date'
task :ukti_stats_since, [:date] => :environment do |_t, args|
  abort 'usage: rake ukti_stats_since[2016-11-14]' unless args[:date]
  begin
    date = Date.parse(args[:date])
  rescue ArgumentError
    abort("#{args[:date].inspect} is not a recognised date")
  end
  time = date.to_time.getlocal
  new_subscriptions = Subscription.where('created_at >= ?', time)
  new_opportunities = Opportunity.where('created_at >= ?', time)
  padding = 8
  pad_with = ' '
  puts <<-EOF
  Opportunities created on or after #{date}
  ------------------------------------------------------------------
  Total created:           #{new_opportunities.count.to_s.rjust(padding, pad_with)}
  of which Published:      #{new_opportunities.publish.count.to_s.rjust(padding, pad_with)}
  of which Pending:        #{new_opportunities.pending.count.to_s.rjust(padding, pad_with)}
  of which Expired:        #{new_opportunities.expired.count.to_s.rjust(padding, pad_with)}
  of which Trash:          #{new_opportunities.trash.count.to_s.rjust(padding, pad_with)}

  Subscriptions created on or after #{date}
  ------------------------------------------------------------------
  Total created:           #{new_subscriptions.count.to_s.rjust(padding, pad_with)}
  of which Confirmed:      #{new_subscriptions.confirmed.active.count.to_s.rjust(padding, pad_with)}
  of which Unconfirmed:    #{new_subscriptions.unconfirmed.active.count.to_s.rjust(padding, pad_with)}
  of which Unsubscribed:   #{new_subscriptions.unsubscribed.count.to_s.rjust(padding, pad_with)}

  Unsubscribes on or after #{date}
  ------------------------------------------------------------------
  Unsubscribes:            #{Subscription.unsubscribed.where('unsubscribed_at >= ?', time).count.to_s.rjust(padding, pad_with)}

  Explanation of Subscriptions
  ------------------------------------------------------------------
  Total          Total number of subscriptions created since
                 #{date}, irrespective of state.
  Confirmed      Subscriptions created since #{date} that will
                 currently receive emails about opportunities.
  Unconfirmed    Subscriptions created since #{date} that, once confirmation is complete,
                 will be able to receive emails about opportunities.
  Unsubscribed   Subscriptions created since #{date} that could
                 once receive emails, but where the user has since
                 opted out. These no longer receive opportunities.
  ------------------------------------------------------------------

  Explanation of Unsubscribes
  ------------------------------------------------------------------
  Unsubscribed   Subscriptions created at any time that could
                 once receive emails, but where the user has opted
                 out since #{date}
  ------------------------------------------------------------------

  EOF
end
