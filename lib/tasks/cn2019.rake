# frozen_string_literal: true

require 'csv'

namespace :cn2019 do
  desc 'Import CN2019 metadata'
  task import: :environment do
    puts 'Importing CN2019 data...'
    csv_text = File.read('db/seed_data/CN2019_METADATA.csv')
    csv      = CSV.parse(csv_text, headers: true)
    total    = csv.size

    csv.each_with_index do |row, idx|
      print "#{idx + 1}/#{total} records (#{(idx + 1) * 100 / total}%)\r"

      Cn2019.new.tap do |obj|
        obj.order              = row[0]
        obj.level              = row[1]
        obj.code               = row[2]
        obj.parent             = row[3] || ''
        obj.code2              = row[4] || ''
        obj.parent2            = row[5] || ''
        obj.description        = row[6]
        obj.english_text       = row[7] || ''
        obj.parent_description = ''
        obj.save
      end
    end

    Cn2019.where.not(parent: nil).each_with_index do |obj, idx|
      print "#{idx + 1}/#{total} records (#{(idx + 1) * 100 / total}%)\r"

      parent = Cn2019.where('code LIKE ?', "%#{obj.parent}%").first
      obj.update_column(:parent_description, parent.english_text)
    end
  end
end
