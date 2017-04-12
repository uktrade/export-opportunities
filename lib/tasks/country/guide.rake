namespace :country do
  namespace :guide do
    desc 'Finds and sets country exporting guides for countries that currently do not have one listed in the database.'
    task set: :environment do
      fails = []
      Country.select { |country| country.exporting_guide_path.nil? }.each do |country|
        uri = URI("https://www.gov.uk/government/publications/exporting-to-#{country.slug}")

        if Faraday.head(uri).status == 404
          print '💣 '
          fails << country
        else
          country.update(exporting_guide_path: uri.path)
          print '.'
        end
      end

      puts "\n\nCountries without guides:"
      fails.sort_by(&:name).each { |country| puts "\t#{country.name} (#{country.slug})" }
    end

    desc 'Checks all country guides in the database to make sure they are still valid links.'
    task check: :environment do
      fails = []
      Country.select { |country| country.exporting_guide_path.present? }.each do |country|
        uri = URI("https://www.gov.uk/#{country.exporting_guide_path}")

        if Faraday.head(uri).status == 404
          print '💣 '
          country.update(exporting_guide_path: nil)
          fails << country
        else
          print '.'
        end
      end

      puts "\n\nCountries with removed guides:"
      fails.sort_by(&:name).each { |country| puts "\t#{country.name} (#{country.slug})" }
    end
  end
end
