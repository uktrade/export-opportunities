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
        large: 'sectors/ExOpps-CTA_Sixth_7_170x255_12@2x.jpg',
        small: 'sectors/ExOpps-CTA_Sixth_7_170x255_12-mob@2x.jpg',
      },
      "education-training": {
        large: 'sectors/ExOpps_CTA_Education_170x255@2x.jpg',
        small: 'sectors/ExOpps_CTA_Education_170x255-mob@2x.png',
      },
      "food-drink": {
        large: 'sectors/ExOpps-CTA_Sixth_11_170x255@2x.jpg',
        small: 'sectors/ExOpps-CTA_Sixth_11_170x255-mob@2x.jpg',
      },
      "oil-gas": {
        large: 'sectors/ExOpps-CTA_OilAndGas_170x255@2x.jpg',
        small: 'sectors/ExOpps-CTA_OilAndGas_170x255-mob@2x.jpg',
      },
      "retail-and-luxury": {
        large: 'sectors/ExOpps-CTA_Sixth_9_170x255@2x.jpg',
        small: 'sectors/ExOpps-CTA_Sixth_9_170x255-mob@2x.jpg',
      },
      "security": {
        large: 'sectors/ExOpps-CTA_Sixth_5_170x255@2x.jpg',
        small: 'sectors/ExOpps-CTA_Sixth_5_170x255-mob@2x.jpg',
      },
    }

    if map.key? name
      map[name]
    else
      {}
    end
  end
end
