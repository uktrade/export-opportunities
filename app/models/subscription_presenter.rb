class SubscriptionPresenter < SimpleDelegator
  include Rails.application.routes.url_helpers
  include RegionHelper

  def description
    out = []
    out << search_term if search_term?
    out << region_and_country_names_array
    out << sector_names_array
    out << type_names_array
    out << value_names_array
    out.flatten!
    if out.any?
      out.join(', ')
    else
      'all opportunities'
    end
  end

  def description_for_email
    default = 'all opportunities'
    desc = description
    if desc == default
      desc.sub(default, '')
    else
      "for #{desc}"
    end
  end

  def country_names
    country_names_array.to_sentence(last_word_connector: ' and ')
  end

  def sector_names
    sector_names_array.to_sentence(last_word_connector: ' and ')
  end

  def type_names
    type_names_array.to_sentence(last_word_connector: ' and ')
  end

  def value_names
    value_names_array.to_sentence(last_word_connector: ' and ')
  end

  def search_path
    params = url_for(
      only_path: true,
      controller: :opportunities,
      action: :index,
      s: search_term,
      countries: countries.map(&:slug),
      sectors: sectors.map(&:slug),
      types: types.map(&:slug),
      values: values.map(&:slug),
      subscription_url: true
    )
    "#{opportunities_path}#{params}"
  end

  def short_description
    if search_term?
      "Search term: #{search_term}"
    elsif filters?
      ''
    else
      'All opportunities'
    end
  end

  private

  def filters?
    countries.any? || sectors.any? || types.any? || values.any?
  end

  def country_names_array
    countries.map(&:name)
  end

  def sector_names_array
    sectors.map(&:name)
  end

  def type_names_array
    types.map(&:name)
  end

  def value_names_array
    values.map(&:name)
  end

  def region_and_country_names_array
    region_and_country_names = []
    regions_and_countries = regions_and_countries_from(countries)
    regions_and_countries[:regions].each do |region|
      region_and_country_names.push(region[:name])
    end
    regions_and_countries[:countries].each do |country|
      region_and_country_names.push(country[:name])
    end
    region_and_country_names
  end
end
