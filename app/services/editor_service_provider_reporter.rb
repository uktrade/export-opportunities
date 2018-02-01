class EditorServiceProviderReporter
  def call
    output = {}
    editors = Editor.where(service_provider_id: nil)
    editors.each do |editor|
      output[editor.id] = editor.opportunities.where.not(service_provider: nil)
        .select(:service_provider_id)
        .group(:service_provider_id)
        .order(count: :desc).count
    end

    output
  end
end
