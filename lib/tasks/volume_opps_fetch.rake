namespace :volume do
  desc 'fetch volume opps'
  task fetch_opps: :environment do
    VolumeOppsRetriever.new.call(Editor.find(1337))
  end
end
