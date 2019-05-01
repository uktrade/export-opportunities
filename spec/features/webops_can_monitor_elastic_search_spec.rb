require 'rails_helper'

feature 'webops can monitor services' do
  before(:each) do
    @redis =  Redis.new(url: Figaro.env.redis_url!)
    @redis.del(:sidekiq_retry_jobs_last_failure)
    @redis.del(:es_data_sync_error_ts)
  end

  scenario 'elastic search, basic check, all is OK' do
    allow_any_instance_of(ApplicationController).to receive(:db_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
    allow_any_instance_of(ApplicationController).to receive(:es_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
    allow_any_instance_of(ApplicationController).to receive(:db_subscriptions).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
    allow_any_instance_of(ApplicationController).to receive(:es_subscriptions).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']

    visit '/export-opportunities/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['status']).to eq('OK')
    expect(res['result']).to eq({})
  end

  scenario 'elastic search, we have an Opportunity object missing in ES' do
    allow_any_instance_of(ApplicationController).to receive(:db_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
    allow_any_instance_of(ApplicationController).to receive(:es_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10']
    
    # first time we see an error, we set redis['es_data_sync_error_ts'] timestamp and return OK, with the missing items in the response
    visit '/export-opportunities/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['status']).to eq('OK')
    expect(res['timeout_sec']).to eq(nil)
    expect(res['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')

    # After 10 minutes we see an error
    Timecop.freeze(15.minutes.from_now) do
      visit '/export-opportunities/data_sync_check'

      res2 = JSON.parse(page.body)
      expect(res2['status']).to eq('error')
      expect(res2['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
    end
  end

  scenario 'elastic search, we have an Opportunity object missing in DB' do
    allow_any_instance_of(ApplicationController).to receive(:db_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10']
    allow_any_instance_of(ApplicationController).to receive(:es_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']

    visit '/export-opportunities/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['status']).to eq('OK')
    expect(res['timeout_sec']).to eq(nil)
    expect(res['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')

    # After 10 minutes we see an error
    Timecop.freeze(15.minutes.from_now) do
      visit '/export-opportunities/data_sync_check'

      res2 = JSON.parse(page.body)
      expect(res2['status']).to eq('error')
      expect(res2['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
    end
  end

  scenario 'elastic search, we have an Opportunity object missing in ES, less than ES_DATA_SYNC_TIMEOUT' do
    allow_any_instance_of(ApplicationController).to receive(:db_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
    allow_any_instance_of(ApplicationController).to receive(:es_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10']

    visit '/export-opportunities/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['timeout_sec']).to eq(nil)

    # After 1 minutes we do not see an error
    Timecop.freeze(1.minute.from_now) do
      visit '/export-opportunities/data_sync_check'

      res2 = JSON.parse(page.body)
      expect(res2['timeout_sec'].to_i).to be < 200
      expect(res2['status']).to eq('OK')
      expect(res2['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
    end
  end

  scenario 'elastic search, we have an Opportunity object missing in DB, less than ES_DATA_SYNC_TIMEOUT' do
    allow_any_instance_of(ApplicationController).to receive(:db_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10']
    allow_any_instance_of(ApplicationController).to receive(:es_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']

    visit '/export-opportunities/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['timeout_sec']).to eq(nil)

    # After 1 minutes we do not see an error
    Timecop.freeze(1.minute.from_now) do
      visit '/export-opportunities/data_sync_check'

      res2 = JSON.parse(page.body)
      expect(res2['timeout_sec'].to_i).to be < 200
      expect(res2['status']).to eq('OK')
      expect(res2['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
    end
  end

  scenario 'elastic search, we have a Subscription missing in ES' do
    allow_any_instance_of(ApplicationController).to receive(:db_subscriptions).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
    allow_any_instance_of(ApplicationController).to receive(:es_subscriptions).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10']

    visit '/export-opportunities/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['timeout_sec']).to eq(nil)

    # After 15 minutes we see an error
    Timecop.freeze(15.minute.from_now) do
      visit '/export-opportunities/data_sync_check'

      res2 = JSON.parse(page.body)
      expect(res2['status']).to eq('error')
      expect(res2['result']['subscriptions']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
    end
  end

  scenario 'elastic search, we have a Subscription missing in DB' do
    allow_any_instance_of(ApplicationController).to receive(:db_subscriptions).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10']
    allow_any_instance_of(ApplicationController).to receive(:es_subscriptions).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']

    visit '/export-opportunities/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['timeout_sec']).to eq(nil)


    # After 15 minutes we see an error
    Timecop.freeze(15.minute.from_now) do
      visit '/export-opportunities/data_sync_check'

      res2 = JSON.parse(page.body)
      expect(res2['status']).to eq('error')
      expect(res2['result']['subscriptions']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
    end
  end

  scenario 'api check, no error' do
    allow_any_instance_of(ApplicationController).to receive(:sidekiq_retry_count).and_return 0
    allow_any_instance_of(ApplicationController).to receive(:redis_oo_retry_count).and_return 0

    visit '/export-opportunities/api_check'

    expect(page.body).to have_content("OK")
  end

  scenario 'api check, 1 new error' do
    allow_any_instance_of(ApplicationController).to receive(:sidekiq_retry_count).and_return 1
    allow_any_instance_of(ApplicationController).to receive(:redis_oo_retry_count).and_return 0

    visit '/export-opportunities/api_check'

    expect(page.body).to have_content("error")
  end

  scenario 'api check, 1 new error, more than 1 day ago' do
    allow_any_instance_of(ApplicationController).to receive(:sidekiq_retry_count).and_return 1
    allow_any_instance_of(ApplicationController).to receive(:redis_oo_retry_count).and_return 0

    visit '/export-opportunities/api_check'

    expect(page.body).to have_content("error")

    tomorrow = Time.zone.now + 1.day + 1.minute
    Timecop.freeze(tomorrow) do
      allow_any_instance_of(ApplicationController).to receive(:sidekiq_retry_count).and_return 1
      allow_any_instance_of(ApplicationController).to receive(:redis_oo_retry_count).and_return 0

      visit '/export-opportunities/api_check'

      expect(page.body).to have_content("OK")
    end
  end
end
