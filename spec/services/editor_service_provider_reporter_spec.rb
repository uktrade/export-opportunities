require 'rails_helper'

RSpec.describe EditorServiceProviderReporter do
  it 'returns a set of key/value pairs representing opportunities per service provider' do
    editor = create(:editor)
    paris = create(:service_provider, name: 'France Paris')
    innsbruck = create(:service_provider, name: 'Austria Innsbruck')

    create_list(:opportunity, 3, service_provider: paris, author: editor)
    create_list(:opportunity, 2, service_provider: innsbruck, author: editor)

    expected_output = {}

    expect(EditorServiceProviderReporter.new.call).to eq expected_output
  end

  it 'does not count "nil" as a service provider' do
    editor = create(:editor)
    paris = create(:service_provider, name: 'France Paris')
    opportunity = FactoryGirl.build(:opportunity, author: editor, service_provider: nil)
    opportunity.save(validate: false)

    create(:opportunity, author: editor, service_provider: paris)

    output = EditorServiceProviderReporter.new.call

    expected_output = {}
    expect(output).to eq expected_output
  end
end
