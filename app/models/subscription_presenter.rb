class SubscriptionPresenter < SimpleDelegator
  include Rails.application.routes.url_helpers

  def description
    out = []
    out << search_term if search_term?
    out << country_names_array
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
    url_for(
      only_path: true,
      controller: :opportunities,
      action: :index,
      s: search_term,
      countries: countries.map(&:slug),
      sectors: sectors.map(&:slug),
      types: types.map(&:slug),
      values: values.map(&:slug),
      suppress_subscription_block: true
    )
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
end
