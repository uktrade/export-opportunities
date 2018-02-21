namespace :volume do
  desc 'fetch volume opps'
  task fetch_opps: :environment do
    VolumeOppsRetriever.new.call(Editor.find(1337))
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
end
