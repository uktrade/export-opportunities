namespace :volume do
  desc 'fetch volume opps'
  task fetch_opps: :environment do
    fetch_date = Figaro.env.OO_FETCH_FROM_DATE
    fetch_date ||= Time.zone.now.strftime('%Y-%m-%d')
    pp fetch_date
    VolumeOppsRetriever.new.call(Editor.find(1337), fetch_date)
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
