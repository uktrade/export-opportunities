class RetrieveVolumeOpps
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    VolumeOppsRetriever.new.call
  end
end
