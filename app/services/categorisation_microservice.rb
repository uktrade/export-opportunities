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
  #   }
  # ]
  #
  def initialize(cpv)
    @cpv = cpv
  end

  def call

    # Potential code...?
    # url = ENV["CATEGORISATION_URL"]
    # secret = ENV["CATEGORISATION_SECRET"]
    # params = @cpv
    # Faraday.get(url, params)

    # Mock:
    return "Error: CPV code not given" unless @cpv
    [
      {
          "sector_id": [
              Sector.first.id,
              20
          ],
          "hsid": 9012,
          "description": "Microscopes (excluding optical microscopes); diffraction apparatus",
          "sectorname": [
              "Biotechnology & Pharmaceuticals",
              "Healthcare & Medical"
          ],
          "cpvid": "38511000"
      }
    ]
  end

  # Gets an array of all of the sector ids from the response
  def sector_ids
    call.map{|result| result[:sector_id] }.flatten
  end

end
