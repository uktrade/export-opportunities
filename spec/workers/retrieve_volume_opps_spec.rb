require 'rails_helper'

RSpec.describe RetrieveVolumeOpps, :elasticsearch, :commit, sidekiq: :inline do

  before do
    allow_any_instance_of(JwtVolumeConnector).to receive(:data).and_return({
      status: 200,
      count: 1,
      data: [{
          "ocid"=>"ocds-0c46vo-0018-21130657",
          "countryname"=>"New Zealand",
          "language"=>"en",
          "source"=>"td_gets_nz",
          "releasedate"=>"2019-06-12T09:00:00Z",
          "date_created"=>"2019-06-12T01:34:51.896083Z",
          "json"=>{
            "uri"=>"https://openopps.com/tenders/ocds-0c46vo-0018-21130657/?format=json",
            "license"=>"https://opendatacommons.org/licenses/odbl/",
            "releases"=>[{
              "id"=>"21130657",
              "tag"=>["tender"],
              "date"=>"2019-06-12T09:00:00+00:00",
              "ocid"=>"ocds-0c46vo-0018-21130657",
              "buyer"=>{
                "name"=>"Ministry of Education - School Infrastructure",
                "address"=>{"countryName"=>"New Zealand"},
                "contactPoint"=>{"name"=>"All queries to be made through the GETS website Q&A function"}
              },
              "tender"=>{
                "id"=>"21130657",
                "items"=>[{"id"=>"1", "classification"=>{"id"=>"72000000", "scheme"=>"CPV"}}],
                "title"=>"Naenae College - Special Needs Upgrades",
                "status"=>"active",
                "documents"=>[{
                  "id"=>"tender_url",
                  "url"=>"https://www.gets.govt.nz/MEDUR/ExternalTenderDetails.htm?id=21130657",
                  "format"=>"text/html",
                  "language"=>"en",
                  "documentType"=>"tenderNotice"
                }],
                "description"=>"The BOT at Naenae College are seeking the services of a main contractor to 
                  undertake the construction of alterations and upgrades as described in the tender documents prepared by IR
                  Group Ltd. This involves the following works:\nAdmin Entrance\n•\tRemove all existing hand rails and any 
                  other obstructing features at Admin entrance\n•\tConstruct new timber deck with accessible ramp as detailed
                  \n•\tInstall high visibility nosing the full length of all steps\nAdmin Courtyard\n•\tRemove any obstructions
                   to construction in admin courtyard\n•\tRemove all existing handrails hand rails, concrete paths as marked and
                    allow to relocate large boulders within courtyard\n•\tAllow to level, compact and apply top soil grass area
                     within admin courtyard\n•\tConstruct new timber deck with accessible ramp as detailed\n•\tConstruct new 
                     concrete path as detailed\n•\tInstall high visibility nosing the full length of all steps\nSee attached 
                     the the relevant tender documents and further details of the work required.\nLibrary entrance\n•\tRemove
                      and dispose of existing timber door units\n•\tInstall new aluminium door unit with hardware as specified
                      \nSite wide\n•\tRemove and dispose of existing aluminium door units\n•\tInstall 6 new aluminium door units
                       with hardware as specified\n•\tInstall 1 new aluminium window unit as detailed\nYB / YC Entrance\n•\t
                       Remove as much existing concrete as is required for construction\n•\tConstruct new concrete accessible 
                       ramp with intermediate platform as detailed\nGym Entrance\n•\tCut out existing area of concrete\n•\t
                       Construct new concrete mini ramp up to door entrance as is detailed\nChannel drain between main and 
                       technology blocks\n•\tSupply and install new stainless steel perforated sheet 2500mm x 800mm to cover
                        existing channel drain\n \nThe project will be a complete turnkey project where the completed building
                         ready for school use will be handed over on completion.  \nSee attached the the relevant tender 
                         documents and further details of the work required.",
                "tenderPeriod"=>{
                  "endDate"=>"2019-07-05T17:00:00+00:00",
                  "startDate"=>"2019-06-12T09:00:00+00:00"},
                  "eligibilityCriteria"=>"None"
                },
                "language"=>"en",
                "initiationType"=>"tender"
              }],
            "publisher"=>{
              "uid"=>"https://beta.companieshouse.gov.uk/company/04962733",
              "uri"=>"https://openopps.com",
              "name"=>"Open Opps",
              "scheme"=>"Companies House"
            },
            "publishedDate"=>"2019-06-12T01:34:18.375914+00:00",
            "publicationPolicy"=>"https://openopps.com/legal/"
          }
        }]
    })
    Country.create(name: "New Zealand", slug: 'new-zealand')
    Type.create(id: 2, name: 'Default', slug: 'default-type')
    Value.create(id: 3, name: 'Default', slug: 'default-value')
    ServiceProvider.create(id: 27, name: 'DIT')
    Editor.create(name: 'test', email: Figaro.env.MAILER_FROM_ADDRESS!, password: 'fsdfs53123f')
  end

  it 'Retrieve Volume Ops runs without raising an error' do
    expect{
      RetrieveVolumeOpps.new.perform
    }.to change{Opportunity.count}.by(1)
  end

end
