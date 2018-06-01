require 'uri'
require 'csv'
require 'rubygems'
require 'net/http'
require 'uri'

namespace :azure do
  desc 'Update list with sensitive terms definitions from file'
  task :import_terms, %i[subscription_key filename list_id] => [:environment] do |_t, args|
    arr_file = CSV.parse(open(args[:filename]))
    arr_file.each do |line|
      next unless line[0]
      element = URI.encode(line[0].downcase)
      uri = uri(element, args[:list_id])

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri)

      request.add_field('Accept', 'application/json')
      request.add_field('Ocp-Apim-Subscription-Key', args[:subscription_key])
      request.add_field('Content-Type', 'application/json')

      response = http.request(request)
      puts response.inspect
    end
  end
end

def uri(term, list_id)
  URI.parse("https://westeurope.api.cognitive.microsoft.com/contentmoderator/lists/v1.0/termlists/#{list_id}/terms/#{term}?language=eng")
end
