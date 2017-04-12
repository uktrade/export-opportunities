namespace :elasticsearch do
  desc 'Import all opportunities into ElasticSearch, deleting and recreating the index'
  task import_opportunities: :environment do
    opportunities = Opportunity.published

    Opportunity.__elasticsearch__.delete_index!
    Opportunity.__elasticsearch__.create_index!

    print "Rebuilding index for #{opportunities.count} opportunities"

    opportunities.find_in_batches(batch_size: 100) do |group|
      print '.'

      group.each do |opp|
        opp.__elasticsearch__.update_document
      end
    end

    puts
  end
end
