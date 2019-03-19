require 'rails_helper'
require 'capybara/email/rspec'


feature 'JS-on adds Companies House API lookup', js: true do
  COMPANIES_HOUSE_SEARCH = 'https://www.great.gov.uk/api/internal/companies-house-search?term='.freeze

  before do
    # @TODO
    # These tests were written with this set to `false`, so
    # they will break if you remove these before/after blocks.
    #
    # When you come to fix the bugs this setting was hiding (!)
    # please remove them.
    Capybara.ignore_hidden_elements = false
  end

  after do
    Capybara.ignore_hidden_elements = true
  end

  before :each do
    @user = create(:user, email: 'test@example.com')
    login_as @user, scope: :user

    opportunity = create(:opportunity, status: 'publish')
    visit enquiries_path(opportunity)
  end

  # JS functionality adds Companies House input show/hide
  scenario 'Companies House input will be enhanced with show/hide functionality' do

    # control created
    expander_control = find_field('has_companies_house_number')
    expect(expander_control['class']).to include('ExpanderControl')

    # target created
    expander_control_target = find('#' + expander_control['aria-controls']) 
    expect(expander_control_target['class']).to include('Expander')

    # control unchecked and expander open
    expect(expander_control.checked?).to be(false)
    expect(expander_control['aria-expanded']).to eql('true')
    expect(expander_control_target['class']).to_not include('collapsed')

    # control checked and expander closed
    expander_control.trigger('click')
    expect(expander_control.checked?).to be(true)
    expect(expander_control['aria-expanded']).to eql('false')
    expect(expander_control_target['class']).to include('collapsed')
  end

  # JS functionality allows Companies House lookup and selection
  scenario 'Entering company name will fetch Companies House data' do
    companies_house_search_url = js_variable('dit.constants.COMPANIES_HOUSE_SEARCH')
    stub_jquery_ajax(companies_house_search_url + '?term=FAKE', companies_house_search_response)

    # Companies House url constant is set
    expect(companies_house_search_url).to include('api/internal/companies-house-search')

    # input field has been enhanced
    company_name_field = find_field('enquiry_company_name')
    expect(company_name_field['aria-expanded']).to eql('false')

    # Companies House information is fetched when user enters data
    company_name_selector = find('#' + company_name_field['aria-owns'])
    company_name_field.send_keys 'FAKE'

    # Wait for $.ajax functionality and DOM manipulation to finish
    sleep 1

    # Lookup data is presented to user 
    expect(company_name_field['aria-expanded']).to eql('true')
    expect(company_name_selector['innerHTML']).to include('PRIZEAGLE LIMITED')

    # User selection will populate company number
    company_number_field = find_field('enquiry[company_house_number]')
    company_choice = find('li', text: 'PRIZEAGLE LIMITED')
    company_choice.trigger('click')

    expect(company_number_field.value).to eql('03166121')
  end


  # Return JS value for checking.
  def js_variable(name)
    id = name.gsub(/[^\w]/, '_')
    page.execute_script("(function() { \
      var text = document.createTextNode(" + name + "); \
      var element = document.createElement('span'); \
      element.setAttribute('id', '" + id + "'); \
      element.appendChild(text); \
      document.body.appendChild(element); \
    })()")
    text = page.find('#' + id).text
    page.execute_script("(function() { \
      var element = document.getElementById('" + id + "'); \
      if(element) { \
        document.body.removeChild(element); \
      } \
    })()")
    text
  end

  # This is complex but can be understood by reading jQuery documentation.
  # https://api.jquery.com/jQuery.ajaxTransport/
  #
  # Essentially, it is creating functionality that will check upon each AJAX
  # request if the requested URL matches the passed url.
  #
  # If URL matches, it will register the request as successful so the success
  # handler will kick in, but it will return the json value that was passed
  # to stub_ajax_request as though it was the retrieved data.
  #
  # The real request will be aborted because we have now faked a response.
  #
  # IMPORTANT: You will get a silent fail (in JS) if the gsub effort is removed.
  def stub_jquery_ajax(url, json)
    page.execute_script("$.ajaxTransport('json', function( options, originalOptions, jqXHR ) { \
        if(options.url == '" + url + "') { \
          return { \
            send: function( headers, completeCallback ) { \
              completeCallback(200, 'success', { text: '" + json.gsub(/"/, '\"') + "' } ); \ 
              jqXHR.abort(); \
            } \
          } \
        } \
        else { \
          console.log('THE URL DID NOT MATCH IN stub_ajax_request\\n'); \
          console.log('options.url: ' + options.url + '\\n'); \
          console.log('passed url: ' + '" + url + "' + '\\n'); \
        } \
      }); \
    ")
  end


  # EXAMPLE Companies House search URL and RESPONSE
  # -----------------------------------------------------------------------
  # URL = 
  # https://www.great.gov.uk/api/internal/companies-house-search/?term=PRIZ
  #
  # RESPONSE =
  def companies_house_search_response
    JSON.generate([
      { "kind": "searchresults#company",
        "company_status": "active",
        "links": {
          "self": "/company/03557664"
        },
        "company_number": "03557664",
        "address_snippet": "50 Coleman Avenue, Hove, East Sussex, BN3 5NB",
        "address": {
          "locality": "Hove",
          "region": "East Sussex",
          "address_line_1": "Coleman Avenue",
          "premises": "50",
          "postal_code": "BN3 5NB"
        },
        "snippet": "",
        "title": "PRIZE LIMITED*******************",
        "matches": {
          "snippet": [],
          "title": [1, 5]
        },
        "description": "03557664 - Incorporated on  5 May 1998",
        "date_of_creation": "1998-05-05",
        "company_type": "ltd",
        "description_identifier": ["incorporated-on"]
      },
      { "kind": "searchresults#company",
        "description": "03166121 - Incorporated on 29 February 1996",
        "links": {
          "self": "/company/03166121"
        },
        "address_snippet": "22-26  King Street, Kings Lynn, Norfolk, PE30 1HJ",
        "company_number": "03166121",
        "date_of_creation": "1996-02-29",
        "address": {
          "locality": "Kings Lynn",
          "region": "Norfolk",
          "address_line_1": "King Street",
          "premises": "22-26 ",
          "postal_code": "PE30 1HJ"
        },
        "snippet": "",
        "title": "PRIZEAGLE LIMITED",
        "matches": {
          "snippet": [],
          "title": [1, 9]
        },
        "company_status": "active",
        "company_type": "ltd",
        "description_identifier": ["incorporated-on"]
      },
      { "kind": "searchresults#company",
        "company_status": "active",
        "snippet": "",
        "address_snippet": "Otterbank Yarde, Williton, Taunton, Somerset, TA4 4HW",
        "company_number": "02077366",
        "date_of_creation": "1986-11-26",
        "address": {
          "locality": "Taunton",
          "region": "Somerset",
          "address_line_1": "Williton",
          "premises": "Otterbank Yarde",
          "postal_code": "TA4 4HW"
        },
        "links": {
          "self": "/company/02077366"
        },
        "title": "PRIZEAMPLE LIMITED",
        "matches": {
          "snippet": [],
          "title": [1, 10]
        },
        "description": "02077366 - Incorporated on 26 November 1986",
        "company_type": "ltd",
        "description_identifier": ["incorporated-on"]
      },
    ])
  end
end
