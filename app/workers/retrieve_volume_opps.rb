class RetrieveVolumeOpps
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    editor = Editor.where(email: Figaro.env.MAILER_FROM_ADDRESS!).first
    VolumeOppsRetriever.new.call(editor)
  end
end
