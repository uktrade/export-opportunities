class CategorisationMicroservice
  #
  # Calls the Categorisation Microservice.
  # This takes a CPV code as an input and returns multiple sector codes
  #
  # Example response:
  # [
  #   {
  #       "sector_id": [
  #           5,
  #           20
  #       ],
  #       "hsid": 9012,
  #       "description": "Microscopes (excluding optical microscopes); diffraction apparatus",
  #       "sectorname": [
  #           "Biotechnology & Pharmaceuticals",
  #           "Healthcare & Medical"
  #       ],
  #       "cpvid": "38511000"
  #   },
  # ]
  #
  def initialize(cpv)
    @cpv = cpv
  end

  # Calls the service and provides a sanitised response
  def call
    return 'Error: CPV code not given' unless @cpv

    url = "#{ENV['CATEGORISATION_URL']}/api/matchers/cpv/?cpv_id=#{@cpv}&format=json"
    response = Faraday.get url

    if response.status == 200
      JSON.parse response.body
    else
      []
    end
  end

  # Gets an array of all of the sector ids from the response
  def sector_ids
    response = call
    if response && response[0] && response[0]['sector_id']
      call.map { |result| result['sector_id'] }.flatten
    else
      []
    end
  end
end
