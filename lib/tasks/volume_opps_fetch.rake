namespace :volume do
  desc 'fetch volume opps'
  task fetch_opps: :environment do
    VolumeOppsRetriever.new.call(Editor.find(1337))
  end

  task delete_opps: :environment do
    volume_opps = Opportunity.where(source: 1)
    volume_opps.delete_all
  end
end
