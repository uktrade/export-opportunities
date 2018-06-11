class LandingPresenter < PagePresenter
  def initialize(content, sector_list)
    super(content)
    @sector_list = sector_list
  end

  def featured_industries
    industries = []
    @sector_list.each do |sector|
      industries.push(
        title: sector.name,
        url: "/opportunities?sectors[]=#{sector.slug}",
        images: sector_images_map(sector.slug),
        alt: '', # Not currently used
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
      "creative-media": {
        large: 'sectors/ExOpps_CTA_Creative_and_media_170x255@2x.jpg',
        small: 'sectors/ExOpps_CTA_Creative_and_media_170x255-mob@2x.png',
      },
      "education-training": {
        large: 'sectors/ExOpps_CTA_Education_170x255@2x.jpg',
        small: 'sectors/ExOpps_CTA_Education_170x255-mob@2x.png',
      },
      "food-drink": {
        large: 'sectors/ExOpps_CTA_Food_and_drink_170x255@2x.jpg',
        small: 'sectors/ExOpps_CTA_Food_and_drink_170x255-mob@2x.png',
      },
      "oil-gas": {
        large: 'sectors/ExOpps_CTA_Oil_and_gas_170x255@2x.jpg',
        small: 'sectors/ExOpps_CTA_Sixth_10_170x255-mob@2x.png',
      },
      "retail-and-luxury": {
        large: 'sectors/ExOpps_CTA_Retail_and_luxury_170x255@2x.jpg',
        small: 'sectors/ExOpps_CTA_Sixth_9_170x255-mob@2x.png',
      },
      "security": {
        large: 'sectors/ExOpps_CTA_Security_170x255@2x.jpg',
        small: 'sectors/ExOpps_CTA_Security_170x255-mob@2x.png',
      },
    }

    if map.key? name
      map[name]
    else
      {}
    end
  end
end
