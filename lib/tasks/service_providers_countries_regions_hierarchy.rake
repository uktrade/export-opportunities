require 'csv'

namespace :reports do
  desc 'Update database with service_providers.country_id , countries.region_id according to internal mapping'
  task load_data: :environment do
    puts 'Adding Regions first:'

    Region.create(id: 1, name: 'Australia - New Zealand').save
    Region.create(id: 2, name: 'Central European Network').save
    Region.create(id: 3, name: 'China Region').save
    Region.create(id: 4, name: 'East Africa').save
    Region.create(id: 5, name: 'Latin America').save
    Region.create(id: 6, name: 'Mediterranean').save
    Region.create(id: 7, name: 'Middle East').save
    Region.create(id: 8, name: 'Nordic/Baltic').save
    Region.create(id: 9, name: 'North Africa').save
    Region.create(id: 10, name: 'North America').save
    Region.create(id: 11, name: 'North East Asia').save
    Region.create(id: 12, name: 'South Asia').save
    Region.create(id: 13, name: 'South East Asia').save
    Region.create(id: 14, name: 'Southern Africa').save
    Region.create(id: 15, name: 'Turkey and Caucuses').save
    Region.create(id: 16, name: 'West Africa').save
    Region.create(id: 17, name: 'Western Europe').save
    Region.create(id: 18, name: 'no region').save

    csv_text = File.read('db/seed_data/sp_country_region_data.csv')
    csv = CSV.parse(csv_text, headers: true)

    puts 'Adding region ids to countries next..'
    csv.each do |row|
      row = row.to_hash

      current_country = row['Country']
      puts "[1]Processing #{current_country}.."

      country = Country.find(row['country_id'])
      country.region_id = row['region_id']

      country.save!
    end

    puts 'Adding country ids to service providers as a final step..'
    csv.each do |row|
      row = row.to_hash

      current_country = row['Country']
      puts "[2]Processing #{current_country}.."

      service_provider = ServiceProvider.find(row['id'])
      service_provider.country_id = row['country_id']

      service_provider.save!

      next unless row['id_obni']
      puts "[2]Adding OBNI to #{current_country}"

      service_provider_obni = ServiceProvider.find(row['id_obni'])
      service_provider_obni.country_id = row['country_id']

      service_provider_obni.save!
    end
  end
end
