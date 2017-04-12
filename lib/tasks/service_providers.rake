namespace :editors do
  desc 'Generate a list of editors who do not have a service provider'
  task service_provider_report: :environment do
    include Rails.application.routes.url_helpers

    counts = EditorServiceProviderReporter.new.call
    editor_emails = Editor.pluck(:id, :email).to_h
    service_provider_names = ServiceProvider.pluck(:id, :name).to_h

    puts 'Editor email,Service providers,Admin url'

    counts.each do |editor_id, opps_per_service_provider|
      next if opps_per_service_provider.empty?

      provider_strings = opps_per_service_provider.collect do |provider_id, opp_count|
        "#{service_provider_names[provider_id].to_s.tr(',', ' ')}: #{opp_count}"
      end

      url = admin_opportunities_url(s: editor_emails[editor_id], host: 'https://www.exportingisgreat.gov.uk')
      puts "#{editor_emails[editor_id]},#{provider_strings.join(' | ')},#{url}"
    end
  end

  desc 'Automatically assign editors a service provider if they always pick the same one'
  task set_service_providers_where_unique: :environment do
    results = EditorServiceProviderReporter.new.call
    unique_relationships = results.select { |_, relationships| relationships.one? }
    editor_ids_and_provider_ids = unique_relationships.map { |e, r| { editor_id: e, service_provider_id: r.keys.first } }

    editor_ids_and_provider_ids.map do |assignment|
      Editor.find(assignment[:editor_id]).update_column(:service_provider_id, assignment[:service_provider_id])
    end

    puts "Updated #{ActionController::Base.helpers.pluralize(editor_ids_and_provider_ids.count, 'relationship')}"
  end
end
