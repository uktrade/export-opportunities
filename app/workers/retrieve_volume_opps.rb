class RetrieveVolumeOpps
  include Sidekiq::Worker

  def perform
    editor = Editor.where(email: Figaro.env.MAILER_FROM_ADDRESS!).first

    today_date = Time.zone.now.strftime('%Y-%m-%d')
    from_date = today_date
    to_date = today_date

    VolumeOppsRetriever.new.call(editor, from_date, to_date)
  end
end
