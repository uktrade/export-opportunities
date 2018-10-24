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

    visit '/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['status']).to eq('OK')
    expect(res['result']).to eq({})
  end

  scenario 'elastic search, we have an Opportunity object missing in ES' do
    allow_any_instance_of(ApplicationController).to receive(:db_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
    allow_any_instance_of(ApplicationController).to receive(:es_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10']
    allow_any_instance_of(ApplicationController).to receive(:report_es_data_sync_timeout).and_return -1

    # first time we see an error, we set redis['es_data_sync_error_ts'] timestamp and return OK, with the missing docs in the
    visit '/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['status']).to eq('OK')
    expect(res['timeout_sec']).to eq(nil)
    expect(res['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')

    # second time we see an error, we fetch redis['es_data_sync_error_ts'] timestamp to compare with the :report_es_data_sync_timeout and decide if we will status= error or OK.
    visit '/data_sync_check'

    res2 = JSON.parse(page.body)
    expect(res2['status']).to eq('error')
    expect(res2['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
  end

  scenario 'elastic search, we have an Opportunity object missing in DB' do
    allow_any_instance_of(ApplicationController).to receive(:db_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10']
    allow_any_instance_of(ApplicationController).to receive(:es_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
    allow_any_instance_of(ApplicationController).to receive(:report_es_data_sync_timeout).and_return -1

    visit '/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['status']).to eq('OK')
    expect(res['timeout_sec']).to eq(nil)
    expect(res['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')

    visit '/data_sync_check'

    res2 = JSON.parse(page.body)
    expect(res2['status']).to eq('error')
    expect(res2['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
  end

  scenario 'elastic search, we have an Opportunity object missing in ES, less than ES_DATA_SYNC_TIMEOUT' do
    allow_any_instance_of(ApplicationController).to receive(:db_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
    allow_any_instance_of(ApplicationController).to receive(:es_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10']
    allow_any_instance_of(ApplicationController).to receive(:report_es_data_sync_timeout).and_return 60

    visit '/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['timeout_sec']).to eq(nil)

    visit '/data_sync_check'

    res2 = JSON.parse(page.body)
    expect(res2['timeout_sec'].to_i).to be < 60
    expect(res2['status']).to eq('OK')
    expect(res2['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
  end

  scenario 'elastic search, we have an Opportunity object missing in DB, less than ES_DATA_SYNC_TIMEOUT' do
    allow_any_instance_of(ApplicationController).to receive(:db_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10']
    allow_any_instance_of(ApplicationController).to receive(:es_opportunities).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
    allow_any_instance_of(ApplicationController).to receive(:report_es_data_sync_timeout).and_return 60

    visit '/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['timeout_sec']).to eq(nil)

    visit '/data_sync_check'

    res2 = JSON.parse(page.body)
    expect(res2['timeout_sec'].to_i).to be < 60
    expect(res2['status']).to eq('OK')
    expect(res2['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
  end

  scenario 'elastic search, we have a Subscription missing in ES' do
    allow_any_instance_of(ApplicationController).to receive(:db_subscriptions).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
    allow_any_instance_of(ApplicationController).to receive(:es_subscriptions).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10']
    allow_any_instance_of(ApplicationController).to receive(:report_es_data_sync_timeout).and_return -1

    visit '/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['timeout_sec']).to eq(nil)

    visit '/data_sync_check'

    res2 = JSON.parse(page.body)
    expect(res2['status']).to eq('error')
    expect(res2['result']['subscriptions']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
  end

  scenario 'elastic search, we have a Subscription missing in DB' do
    allow_any_instance_of(ApplicationController).to receive(:db_subscriptions).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10']
    allow_any_instance_of(ApplicationController).to receive(:es_subscriptions).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
    allow_any_instance_of(ApplicationController).to receive(:report_es_data_sync_timeout).and_return -1

    visit '/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['timeout_sec']).to eq(nil)

    visit '/data_sync_check'

    res2 = JSON.parse(page.body)
    expect(res2['status']).to eq('error')
    expect(res2['result']['subscriptions']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
  end

  scenario 'api check, no error' do
    allow_any_instance_of(ApplicationController).to receive(:sidekiq_retry_count).and_return 0
    allow_any_instance_of(ApplicationController).to receive(:redis_oo_retry_count).and_return 0

    visit '/api_check'

    expect(page.body).to have_content("OK")
  end

  scenario 'api check, 1 new error' do
    allow_any_instance_of(ApplicationController).to receive(:sidekiq_retry_count).and_return 1
    allow_any_instance_of(ApplicationController).to receive(:redis_oo_retry_count).and_return 0

    visit '/api_check'

    expect(page.body).to have_content("error")
  end

  scenario 'api check, 1 new error, more than 1 day ago' do
    allow_any_instance_of(ApplicationController).to receive(:sidekiq_retry_count).and_return 1
    allow_any_instance_of(ApplicationController).to receive(:redis_oo_retry_count).and_return 0

    visit '/api_check'

    expect(page.body).to have_content("error")

    tomorrow = Time.zone.now + 1.day + 1.minute
    Timecop.freeze(tomorrow) do
      allow_any_instance_of(ApplicationController).to receive(:sidekiq_retry_count).and_return 1
      allow_any_instance_of(ApplicationController).to receive(:redis_oo_retry_count).and_return 0

      visit '/api_check'

      expect(page.body).to have_content("OK")
    end
  end
end
