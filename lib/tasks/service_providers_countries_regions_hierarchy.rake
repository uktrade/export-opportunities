require 'csv'

namespace :partners do
  desc 'update service providers with partner names'
  task add: :environment do
    bcc_providers = []
    # burma
    bcc_providers <<   ServiceProvider.where(name: 'Burma OBNI').first
    # cambodia
    bcc_providers <<   ServiceProvider.where(name: 'Cambodia OBNI').first
    # chile
    bcc_providers <<   ServiceProvider.where(name: 'Chile OBNI').first
    # czech
    bcc_providers <<   ServiceProvider.where(name: 'Czech Republic OBNI').first
    # ghana
    bcc_providers <<   ServiceProvider.where(name: 'Ghana OBNI').first
    # hungary
    bcc_providers <<   ServiceProvider.where(name: 'Hungary OBNI').first
    # indonesia
    bcc_providers <<   ServiceProvider.where(name: 'Indonesia OBNI').first
    # kazakhstan
    bcc_providers <<   ServiceProvider.where(name: 'Kazakhstan OBNI').first
    # korea
    bcc_providers <<   ServiceProvider.where(name: 'Korea (South) OBNI').first
    # morocco
    bcc_providers <<   ServiceProvider.where(name: 'Morocco OBNI').first
    # philippines
    bcc_providers <<   ServiceProvider.where(name: 'Philippines, OBNI').first
    # qatar
    bcc_providers <<   ServiceProvider.where(name: 'Qatar, OBNI').first
    # singapore
    bcc_providers <<   ServiceProvider.where(name: 'Singapore OBNI').first
    # slovakia
    bcc_providers <<   ServiceProvider.where(name: 'Slovakia OBNI').first
    # slovenia
    bcc_providers <<   ServiceProvider.where(name: 'Slovenia OBNI').first
    # thailand
    bcc_providers <<   ServiceProvider.where(name: 'Thailand OBNI').first

    bcc_providers.each do |bcc_provider|
      bcc_provider.partner = 'British Chamber of Commerce'
      bcc_provider.save!
    end

    china = ServiceProvider.where(name: 'China - CBBC').first
    china.partner = 'China-Britain Business Council (CBBC)'
    china.save!

    colombia = ServiceProvider.where(name: 'Colombia OBNI').first
    colombia.partner = 'UK Colombia Trade'
    colombia.save!

    india = ServiceProvider.where(name: 'India OBNI').first
    india.partner = 'UK India Business Council (UKIBC)'
    india.save!

    japan = ServiceProvider.where(name: 'Japan OBNI').first
    japan.partner = 'Export to Japan'
    japan.save!

    kuwait = ServiceProvider.where(name: 'Kuwait OBNI').first
    kuwait.partner = 'Kuwait British Business Centre (KBBC)'
    kuwait.save!

    malaysia = ServiceProvider.where(name: 'Malaysia OBNI').first
    malaysia.partner = 'British Malaysian Chamber of Commerce (BMCC)'
    malaysia.save!

    pakistan = ServiceProvider.where(name: 'Pakistan OBNI').first
    pakistan.partner = 'British Business Centre'
    pakistan.save!

    poland = ServiceProvider.where(name: 'Poland OBNI').first
    poland.partner = 'British Polish Chamber of Commerce'
    poland.save!

    romania = ServiceProvider.where(name: 'Romania OBNI').first
    romania.partner = 'British Romanian Chamber of Commerce'
    romania.save!

    taiwan = ServiceProvider.where(name: 'Taiwan OBNI').first
    taiwan.partner = 'British Chamber of Commerce in Taipei (BCCT)'
    taiwan.save!

    turkey = ServiceProvider.where(name: 'Turkey OBNI').first
    turkey.partner = 'British Chamber of Commerce in Turkey (BCCT)'
    turkey.save!

    uae = ServiceProvider.where(name: 'United Arab Emirates OBNI').first
    uae.partner = 'British Centre for Business'
    uae.save!

    vietnam = ServiceProvider.where(name: 'Vietnam OBNI').first
    vietnam.partner = 'British Business Group Vietnam (BBGV)'
    vietnam.save!

    saudi_ar = ServiceProvider.where(name: 'Saudi Arabia OBNI').first
    saudi_ar.partner = 'Arabian Enterprise Incubators'
    saudi_ar.save!
  end
end

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
