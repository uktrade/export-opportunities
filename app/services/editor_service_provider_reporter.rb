class EditorServiceProviderReporter
  def call
    output = {}
    editors = Editor.where(service_provider_id: nil)
    editors.each do |editor|
      # { editor_id: { service_provider_id_1: 12, service_provider_id_n: n } }
      output[editor.id] = editor.opportunities.where.not(service_provider: nil)
        .select(:service_provider_id)
        .group(:service_provider_id)
        .order(count: :desc).count
    end

    output
  end
end
