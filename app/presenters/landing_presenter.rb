class LandingPresenter < PagePresenter
  def initialize(content, sector_list)
    super(content)
    @sector_list = sector_list
  end

  def description(count = 0)
    if count.present? && count.positive?
      number = content_tag('span', number_with_delimiter(count, delimiter: ','), class: 'number')
      content_with_inclusion 'description', [number]

    else
      content_without_inclusion 'description'
    end
  end

  def featured_industries
    industries = []
    @sector_list.each do |sector|
      industries.push(
        title: sector.name,
        url: "/export-opportunities/opportunities?sectors[]=#{sector.slug}",
        images: sector_images_map(sector.slug),
        alt: '' # Not currently used
      )
    end
    industries
  end

  private

    # Workaround for cross-referencing sector slugs
    # to design-named desktop/mobile image versions.
    def sector_images_map(key)
      name = key.to_sym
      map = {
        "creative-industries": {
          small: 'sectors/ExOpps-CTA_Mobile_CreativeIndustries_Square.jpg',
          large: 'sectors/ExOpps-CTA_Mobile_CreativeIndustries_Tall.jpg',
        },
        "education-training": {
          small: 'sectors/ExOpps_CTA_Education_Square.png',
          large: 'sectors/ExOpps_CTA_Education_Tall.jpg',
        },
        "food-and-drink": {
          small: 'sectors/ExOpps-CTA_FoodAndDrink_Square.jpg',
          large: 'sectors/ExOpps-CTA_FoodAndDrink_Tall.jpg',
        },
        "technology-smart-cities": {
          small: 'sectors/ExOpps-CTA_TechnologyAndSmartCities_Square.jpg',
          large: 'sectors/ExOpps-CTA_TechnologyAndSmartCities_Tall.jpg',
        },
        "consumer-and-retail": {
          small: 'sectors/ExOpps-CTA_ConsumerAndRetail_Square.jpg',
          large: 'sectors/ExOpps-CTA_ConsumerAndRetail_Tall.jpg',
        },
        "security": {
          small: 'sectors/ExOpps-CTA_Security_Square.jpg',
          large: 'sectors/ExOpps-CTA_Security_Tall.jpg',
        },
      }

      if map.key? name
        map[name]
      else
        {}
      end
    end
end
