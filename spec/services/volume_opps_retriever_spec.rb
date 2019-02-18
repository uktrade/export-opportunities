require 'rails_helper'

RSpec.describe VolumeOppsRetriever do
  describe '#call' do
    it 'retrieves opps in volume' do
      editor = create(:editor)
      country = create(:country, id: '11')
      create(:sector, id: '2')
      create(:type, id: '3')
      create(:value, id: '3')
      create(:service_provider, id: '150', country: country)

      allow_any_instance_of(VolumeOppsRetriever).to receive(:jwt_volume_connector_token).and_return(OpenStruct.new(body: "{\"token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9\"}"))
      allow_any_instance_of(OpportunitySensitivityRetriever).to receive(:personal_identifiable_information).and_return({name: 'Mark Lytollis', phone: '02072155000'})

      file_response = File.read('spec/files/volume_opps/response_hash.json')
      response_opps = JSON.parse(file_response, quirks_mode: true)
      json_response_opps = JSON.parse(response_opps).with_indifferent_access
      allow_any_instance_of(VolumeOppsRetriever).to receive(:jwt_volume_connector_data).and_return(json_response_opps)

      res = VolumeOppsRetriever.new.call(editor, '2018-04-16', '2018-04-16')

      expect(res[0][:ocid]).to eq('ocds-0c46vo-0018-19461899')
      expect(res[0][:json][:releases][0][:buyer][:contactPoint][:name]).to eq('Mark Lytollis, 02072155000')
    end

    it 'retrieves opps in volume, an opp that already exists' do
      editor = create(:editor)
      country = create(:country, id: '11', name: 'New Zealand')
      create(:sector, id: '2')
      create(:type, id: '3')
      create(:type, id: '2')
      create(:value, id: '2')
      create(:value, id: '3')
      create(:service_provider, id: '150', country: country)

      allow_any_instance_of(VolumeOppsRetriever).to receive(:jwt_volume_connector_token).and_return(OpenStruct.new(body: "{\"token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9\"}"))
      allow_any_instance_of(OpportunitySensitivityRetriever).to receive(:personal_identifiable_information).and_return({name: 'Mark Lytollis', phone: {number: '02072155000'}})

      file_response = File.read('spec/files/volume_opps/response_hash.json')
      response_opps = JSON.parse(file_response, quirks_mode: true)
      json_response_opps = JSON.parse(response_opps).with_indifferent_access
      allow_any_instance_of(VolumeOppsRetriever).to receive(:jwt_volume_connector_data).and_return(json_response_opps)

      VolumeOppsRetriever.new.call(editor, '2018-04-16', '2018-04-16')

      res = VolumeOppsRetriever.new.call(editor, '2018-04-16', '2018-04-16')

      expect(res[0][:ocid]).to eq('ocds-0c46vo-0018-19461899')
      expect(res[0][:json][:releases][0][:buyer][:contactPoint][:name]).to eq('Mark Lytollis, 02072155000')
    end
  end

  describe '#opportunity_params' do
    before do
      create(:country, name: 'eSwatini')
      @service_provider = create(:service_provider, id: 27, name: 'DIT HQ')
      @editor = create(:editor, service_provider: @service_provider)
      create(:sector, id: 2)
      create(:type, id: 2)
      create(:value, id: 2)
    end

    it 'validates and saves a valid opp' do
      opp = build_opportunity_hash

      params = VolumeOppsRetriever.new.opportunity_params(opp)

      res = VolumeOppsValidator.new.validate_each(params)

      expect(res).to eq(true)

      CreateOpportunity.new(@editor, :draft, :volume_opps).call(params)

      saved_opp = Opportunity.first

      expect(Opportunity.count).to eq(1)
      expect(saved_opp.title).to eq(opp['json']['releases'][0]['tender']['title'])
      expect(saved_opp.description).to eq(opp['json']['releases'][0]['tender']['description'])
      expect(saved_opp.description).to_not eq(nil)
    end

    it 'saves an opportunity without description' do
      opp = build_opportunity_hash

      opp['json']['releases'][0]['tender']['description'] = nil

      params = VolumeOppsRetriever.new.opportunity_params(opp)
      res = VolumeOppsValidator.new.validate_each(params)

      expect(res).to eq(true)

      CreateOpportunity.new(@editor, :draft, :volume_opps).call(params)

      saved_opp = Opportunity.first

      expect(Opportunity.count).to eq(1)
      expect(saved_opp.title).to eq(opp['json']['releases'][0]['tender']['title'])
      expect(saved_opp.description).to eq(opp['json']['releases'][0]['tender']['description'])
      expect(saved_opp.description).to eq(nil)
    end

    it 'rejects an opportunity without country' do
      create(:country, name: 'eSwatini')
      opp = build_opportunity_hash
      opp['countryname'] = nil

      params = VolumeOppsRetriever.new.opportunity_params(opp)

      expect(params).to eq(nil)
    end

    it 'rejects an opportunity without a valid tender URL' do
      create(:country, name: 'eSwatini')

      opp = build_opportunity_hash

      opp['json']['releases'][0]['tender']['documents'][0]['url'] = nil

      params = VolumeOppsRetriever.new.opportunity_params(opp)

      expect(params).to eq(nil)
    end
  end

  describe '#contact_attributes' do
    it 'returns nil if no contactpoint present' do
      res = VolumeOppsRetriever.new.contact_attributes({})
      expect(res[0][:name]).to eq nil
      expect(res[0][:email]).to eq nil
    end

    it 'strips email/address from name field, adds them to email overwriting existing entry' do
      skip('TODO: deprecated functionality, to remove or reintroduce')
      res = VolumeOppsRetriever.new.contact_attributes({contactPoint: {name: 'alex giamas agiamasat@gmail.com Westminster, London SW1A 1AA', email: 'aninvalidemail'}}.with_indifferent_access)

      expect(res[0][:name]).not_to include('agiamasat@gmail.com')
      expect(res[0][:email]).to eq('agiamasat@gmail.com')
    end

    it 'strips address from email field' do
      skip('TODO: implement')
    end
  end

  describe '#calculate_value' do
    it 'converts values to GBP in opps, from a known currency, using seed exchange data, under 100,000GBP' do
      gbp_value = VolumeOppsRetriever.new.calculate_value(OpenStruct.new({amount: 1000, currency: 'PHP'}))

      expect(gbp_value[:id]).to eq 2
      expect(gbp_value[:gbp_value]).to eq 13.77
    end

    it 'converts values to GBP in opps, from a known currency, using seed exchange data, over 100,000GBP' do
      gbp_value = VolumeOppsRetriever.new.calculate_value(OpenStruct.new({amount: 141487.75, currency: 'USD'}))

      expect(gbp_value[:id]).to eq 2
      expect(gbp_value[:gbp_value]).to eq 99999.47
    end

    it 'converts values to GBP in opps, from an unknown currency' do
      gbp_value = VolumeOppsRetriever.new.calculate_value(OpenStruct.new({amount: 100000000, currency: 'GRD'}))

      expect(gbp_value[:id]).to eq 3
      expect(gbp_value[:gbp_value]).to eq -1
    end
  end


  describe '#fixes title' do
    it 'do nothing if there is not a dot in the end and length is less or equal to 250 chars' do
      title = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu pretiu250"
      trimmed_title = VolumeOppsRetriever.new.clean_title(title)

      expect(trimmed_title).to eq(title)
    end

    it 'removes last dot if there is one and the title is less or equal to 250 chars' do
      title = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec pellentesque eu pretiu250."
      trimmed_title = VolumeOppsRetriever.new.clean_title(title)

      expect(trimmed_title).to_not end_with('.')
    end

    it 'adds ... at the end of the title if the title is more than 250 chars' do
      title = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretiu251"
      trimmed_title = VolumeOppsRetriever.new.clean_title(title)

      expect(trimmed_title).to end_with('...')
    end
  end

  describe '#translates opportunity' do
    it 'translates a sample opp' do
      skip('TODO: add the tests here in a periodically running suite')
      opportunity = create(:opportunity, description: 'alex jest świetny, niech żyje alex', original_language: 'pl')

      VolumeOppsRetriever.new.translate(opportunity, [:description, :teaser, :title], 'pl')

      expect(opportunity.description).to eq('alex is great, let alex live')
      expect(opportunity.original_language).to eq('pl')
    end

    it 'queries translate API to translate the opportunity' do
      skip('TODO: add the tests here in a periodically running suite')
      opportunity = create(:opportunity,
                           source: :volume_opps,
                           original_language: 'fr',
                           title: "Refonte de l'application métier Matys

Numéro de référence: DHA_2018SIT12812",
                           teaser: "Les prestations incluses dans le périmètre du marché sont décrites ci-dessous:

Prestations du montant minimum:

— refonte de l'application Matys, incluant le maintien en condition opérationnelle pendant la période de garantie.

Prestations du montant maximum:

— prestations du montant minimum,

— prestations associées, pour un volume maximum de 300 jours.",
                           description: "L’application Matys de la RATP est une application métier destinée aux études du domaine ferroviaire.

Elle permet notamment aujourd’hui le calcul des marches-types, du temps de parcours et des intervalles des trains ainsi que l’implantation de la signalisation lors des études projet.

L’application métier Matys doit à présent évoluer afin de traiter efficacement son obsolescence technique, son industrialisation, son besoin de normalisation et son intégration pérenne dans le système d’information de la RATP.

Ce système, basé sur d’anciennes technologies constitue un risque fort au niveau du maintien en condition opérationnelle, et une limite forte pour intégrer les demandes d’évolution des besoins métiers.

Les langages utilisés et à considérer comme obsolètes sont Matrix, Matlab, Fortran, C et autres analogues à modifier. Dans ce contexte, l'objectif principal est de maintenir le niveau de savoir-faire présent dans le code du logiciel tout en modernisant le cœur du produit.",
                           tender_url: 'https://ted.europa.eu/udl?uri=TED:NOTICE:354260-2018:TEXT:EN:HTML&src=0&tabId=1')

      VolumeOppsRetriever.new.translate(opportunity, [:description, :teaser, :title], 'fr')
      expect(opportunity.original_language).to eq('fr')
      expect(opportunity.title).to include('Redesign of the Matys business application')
      expect(opportunity.description).to include("RATP's Matys application is a business application for railway studies")
      expect(opportunity.teaser).to include('The services included in the market scope are described below')
    end

    skip('TODO: add the tests here in a periodically running suite')
    it 'fails gracefully when translate API fails' do
      stub_request(:post, Figaro.env.DL_HOSTNAME).to_timeout
      opportunity = create(:opportunity, description: 'alex jest świetny, niech żyje alex', original_language: 'pl')

      expect { VolumeOppsRetriever.new.translate(opportunity, [:description, :teaser, :title], 'pl') }.to raise_error(Net::OpenTimeout)
    end

    skip('TODO: add the tests here in a periodically running suite')
    it 'should not return 414 when the request-uri is too long' do
      opportunity = create(:opportunity, description: Faker::Lorem::characters(8100), original_language: 'pl')

      expect { VolumeOppsRetriever.new.translate(opportunity, [:description], 'pl') }.to_not raise_error
    end

    it 'will try to translate non english text' do
      expect(VolumeOppsRetriever.new.should_translate?('pl')).to eq true
    end

    it 'will not try to translate english en text' do
      expect(VolumeOppsRetriever.new.should_translate?('en')).to eq false
    end

    it 'will not try to translate english en-GB text' do
      expect(VolumeOppsRetriever.new.should_translate?('en-GB')).to eq false
    end
  end

  private def build_opportunity_hash
    return {
        countryname: 'eSwatini',
        source: 'test source',
        ocid: '2018-09-22-vlsgrc',
        language: 'en',
        json: {
            releases: [
                language: 'en',
                tender: {
                    tenderPeriod: {
                        endDate: '2018-09-13'
                    },
                    title: 'test title',
                    description: 'an optional description..',
                    documents: [
                        id: 'tender_url',
                        url: 'http://great.gov.uk/fantastic_opportunities'
                    ],
                    items: [
                        classification: {
                            id: '1234',
                            scheme: 'cpv'
                        }
                    ]
                },
                planning: {
                    budget: {
                        amount: {
                          amount: 1000,
                          currency: 'EUR'
                        }
                    }
                },
                buyer: {
                    name: 'alex',
                    address: '50 victoria street'
                }
            ]
        }
    }.with_indifferent_access
  end
end
