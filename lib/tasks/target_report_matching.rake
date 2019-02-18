# simple ruby script to process a CSV file with the following format:
# Country,PTarget,RTarget
# lines of data...
# and update our database
require 'csv'

namespace :reports do
  desc 'Update database with publish and response targets per country'
  task load_targets: :environment do
    arr_file = CSV.parse(open(Figaro.env.REPORT_TARGETS_URL))
    arr_file.each_with_index do |data, line|
      next if line.zero?

      if line == arr_file.size - 1
        # puts "NBN"
        # puts data
        # NBN = arr_file[arr_file.size-1]
      elsif line == arr_file.size - 2
        # puts "CEN"
        # puts data
        # CEN = arr_file[arr_file.size-2]
      else
        puts 'data line'
        country = data[0]
        published_target = data[1]
        responses_target = data[2]

        matched_country = Country.where('name ILIKE ?', country).first
        puts ">> #{country} : #{matched_country&.name} <<"
        if matched_country
          matched_country.published_target = published_target
          matched_country.responses_target = responses_target
          matched_country.save!
        end
      end
    end
  end
end
