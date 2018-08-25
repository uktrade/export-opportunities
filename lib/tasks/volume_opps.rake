namespace :volume do
  desc 'fetch volume opps'
  task :fetch_opps, %i[from_date to_date] => [:environment] do |_t, args|
    from_date = if args[:from_date]
                  args[:from_date]
                else
                  ENV['OO_FETCH_FROM_DATE']
                end
    to_date = if args[:to_date]
                args[:to_date]
              else
                ENV['OO_FETCH_FROM_DATE']
              end

    # all volume opps will be assigned to the following editor, needs to be present in DB
    VolumeOppsRetriever.new.call(Editor.where(email: ENV['MAILER_FROM_ADDRESS']).first, from_date, to_date)
  end

  task delete_opps: :environment do
    volume_opps = Opportunity.where(source: 1)
    volume_opps.delete_all
  end

  task delete_all_checks: :environment do
    # delete all opportunity checks from opportunities that we already have stored
    Opportunity.all.each do |opp|
      OpportunityCheck.delete(opportunity_id: opp.id)
    end
  end

  task check_opps: :environment do
    # check all opportunities now
    Opportunity.all.each do |opp|
      OppsQualityValidator.new.call(opp) unless OpportunityCheck.where(opportunity_id: opp.id).length.positive?
    end
  end

  task sensitivity_check_opps: :environment do
    Opportunity.all.each do |opp|
      OppsSensitivityValidator.new.call(opp) unless OpportunitySensitivityCheck.where(opportunity_id: opp.id).length.positive?
    end
  end
end
