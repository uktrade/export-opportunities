require 'rails_helper'

feature 'webops can monitor elastic search' do
  scenario 'basic check, all is OK' do
    allow_any_instance_of(ApplicationController).to receive(:get_db_opportunities).and_return ["8c11755c-3c39-44cd-8b4e-7527bbc7aa10", "5bb688c2-391e-490a-9e4b-d0183040e9de"]
    allow_any_instance_of(ApplicationController).to receive(:get_es_opportunities).and_return ["8c11755c-3c39-44cd-8b4e-7527bbc7aa10", "5bb688c2-391e-490a-9e4b-d0183040e9de"]
    allow_any_instance_of(ApplicationController).to receive(:get_db_subscriptions).and_return ["8c11755c-3c39-44cd-8b4e-7527bbc7aa10", "5bb688c2-391e-490a-9e4b-d0183040e9de"]
    allow_any_instance_of(ApplicationController).to receive(:get_es_subscriptions).and_return ["8c11755c-3c39-44cd-8b4e-7527bbc7aa10", "5bb688c2-391e-490a-9e4b-d0183040e9de"]


    visit '/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['status']).to eq('OK')
  end

  scenario 'we have an Opportunity object missing in ES' do
    allow_any_instance_of(ApplicationController).to receive(:get_db_opportunities).and_return ["8c11755c-3c39-44cd-8b4e-7527bbc7aa10", "5bb688c2-391e-490a-9e4b-d0183040e9de"]
    allow_any_instance_of(ApplicationController).to receive(:get_es_opportunities).and_return ["8c11755c-3c39-44cd-8b4e-7527bbc7aa10"]

    visit '/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['status']).to eq('error')
    expect(res['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')


  end

  scenario 'we have an Opportunity object missing in DB' do
    allow_any_instance_of(ApplicationController).to receive(:get_db_opportunities).and_return ["8c11755c-3c39-44cd-8b4e-7527bbc7aa10"]
    allow_any_instance_of(ApplicationController).to receive(:get_es_opportunities).and_return ["8c11755c-3c39-44cd-8b4e-7527bbc7aa10", "5bb688c2-391e-490a-9e4b-d0183040e9de"]

    visit '/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['status']).to eq('error')
    expect(res['result']['opportunities']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
  end

  scenario 'we have a Subscription missing in ES' do
    allow_any_instance_of(ApplicationController).to receive(:get_db_subscriptions).and_return ["8c11755c-3c39-44cd-8b4e-7527bbc7aa10", "5bb688c2-391e-490a-9e4b-d0183040e9de"]
    allow_any_instance_of(ApplicationController).to receive(:get_es_subscriptions).and_return ["8c11755c-3c39-44cd-8b4e-7527bbc7aa10"]

    visit '/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['status']).to eq('error')
    expect(res['result']['subscriptions']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
  end

  scenario 'we have a Subscription missing in DB' do
    allow_any_instance_of(ApplicationController).to receive(:get_db_subscriptions).and_return ["8c11755c-3c39-44cd-8b4e-7527bbc7aa10"]
    allow_any_instance_of(ApplicationController).to receive(:get_es_subscriptions).and_return ["8c11755c-3c39-44cd-8b4e-7527bbc7aa10", "5bb688c2-391e-490a-9e4b-d0183040e9de"]

    visit '/data_sync_check'

    res = JSON.parse(page.body)
    expect(res['status']).to eq('error')
    expect(res['result']['subscriptions']['missing'].first).to eq('5bb688c2-391e-490a-9e4b-d0183040e9de')
  end
end




