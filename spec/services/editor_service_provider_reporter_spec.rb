require 'rails_helper'

RSpec.describe EditorServiceProviderReporter do
  it 'returns a set of key/value pairs representing opportunities per service provider' do
    skip('test is outdated now that we dont allow service_provider_id=nil for editors')
    editor = create(:editor)
    paris = create(:service_provider, name: 'France Paris')
    innsbruck = create(:service_provider, name: 'Austria Innsbruck')

    create_list(:opportunity, 3, service_provider: paris, author: editor)
    create_list(:opportunity, 2, service_provider: innsbruck, author: editor)
    # Expected mappings:
    #
    # {
    #   editor.id: {
    #     paris.id: 3,
    #     innsbruck.id: 2
    #   }
    # }
    expected_mappings = {}
    expected_mappings[paris.id] = 3
    expected_mappings[innsbruck.id] = 2

    expected_output = {}
    expected_output[editor.id] = expected_mappings

    expect(EditorServiceProviderReporter.new.call).to eq expected_output
  end

  it 'does not count "nil" as a service provider' do
    skip('test is outdated now that we dont allow service_provider_id=nil for editors')
    editor = create(:editor)
    paris = create(:service_provider, name: 'France Paris')
    opportunity = FactoryGirl.build(:opportunity, author: editor, service_provider: nil)
    opportunity.save(validate: false)

    create(:opportunity, author: editor, service_provider: paris)

    output = EditorServiceProviderReporter.new.call

    expected_mappings = {}
    expected_mappings[paris.id] = 1

    expected_output = {}
    expected_output[editor.id] = expected_mappings
    expect(output).to eq expected_output
  end
end
