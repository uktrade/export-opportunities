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
    Rails.logger.error("VOLUMEOPS - Categorizing...")
    Rails.logger.error("VOLUMEOPS - CPV: #{@cpv}")

    url = "#{ENV['CATEGORISATION_URL']}/api/matchers/cpv/?cpv_id=#{@cpv}&format=json"
    response = Faraday.get url

    if response.status == 200
      Rails.logger.error("VOLUMEOPS - Categorizing... done")
      response = JSON.parse response.body
      Rails.logger.error("VOLUMEOPS - Response: #{response}")
      response
    else
      Rails.logger.error("VOLUMEOPS - Categorizing... done")
      Rails.logger.error("VOLUMEOPS - Categorizing as []")
      []
    end
  end

  # Gets an array of all of the sector ids from the response
  def sector_ids
    response = call
    Rails.logger.error("VOLUMEOPS - Categorizing... saving sector_ids")
    if response && response[0] && response[0]['sector_id']
      ids = response.map { |result| result['sector_id'] }.flatten
      Rails.logger.error("VOLUMEOPS - Sector_ids: #{ids}")
      ids
    else
      Rails.logger.error("VOLUMEOPS - Sector_ids: []")
      []
    end
  end
end
