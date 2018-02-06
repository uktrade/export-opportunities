namespace :volume do
  desc 'fetch volume opps'
  task fetch_opps: :environment do
    VolumeOppsRetriever.new.call(Editor.find(1337))
  end

  task delete_opps: :environment do
    volume_opps = Opportunity.where(source: 1)
    volume_opps.delete_all
  end

  task check_opps :environment do
    # delete all opportunity checks from opportunities that we already have stored
    Opportunity.all.each do |opp|
      OpportunityCheck.delete(opportunity_id: opp.id)
    end

    # check all opportunities now
    Opportunity.all.each do |opp|
      OppsQualityValidator.new.call(opp)
    end
  end
end
