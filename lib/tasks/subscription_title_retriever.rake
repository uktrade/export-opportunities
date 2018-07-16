desc 'Task to assign title to subscriptions'
namespace :subscriptions do
  task create_title: :environment do
    st = subscription('cars', [Country.first.name, Country.last.name])
  end
end

def subscription(term, countries_list)
  what = searched_for(false, term)
  where = searched_in(false, countries_list)
  {
      title: (what + where).sub(/\sin\s|\sfor\s/, ''), # strip out opening ' in ' or ' for '
      what: what,
      where: where,
  }
end

# Add to 'X results found' message
# Returns ' for [your term here]' or ''
def searched_for(with_html = false, term)
  message = ''
  if term.present?
    message = ' for '
    message += if with_html
                 content_tag('span', term.to_s, 'class': 'param')
               else
                 term.to_s
               end
  else
    message += ' for all opportunities '
  end
  message.html_safe
end

# Add to 'X results found' message
# Returns ' in [a country name here]' or ''
def searched_in(with_html = false, selected_list)
  message = ''
  separator_in = ' in '
  list = []
  if selected_list.length.positive?
    separator_or = ' or '

    # If HTML is required, wrap things in tags.
    if with_html
      separator_in = content_tag('span', separator_in, 'class': 'separator')
      separator_or = content_tag('span', separator_or, 'class': 'separator')
      selected_list.each_index do |i|
        list.push(content_tag('span', selected_list[i], 'class': 'param'))
      end
    else
      list = selected_list
    end

    # Make it a string and remove any trailing separator_or
    message = list.join(separator_or)
    message = message.sub(Regexp.new("(.+)\s" + separator_or + "\s"), '\\1')
  end

  # Return message (if not empty, add prefix separator)
  message.sub(/^(.+)$/, separator_in + '\\1').html_safe
end

# TODO: Could be stored in DB but writing here.
# DB has regions but no country ids added to any.
# DB regions also differ slightly in names.
# Structure is based on what we get in other filters,
# e.g. matches structure of Sector.order(:name)
# countries need to be
private def country_to_regions_list(countries)
  regions = [
      { slug: 'australia_new_zealand',
        countries: %w[australia fiji new-zealand papua-new-guinea],
        name: 'Australia/New Zealand' },
      { slug: 'caribbean',
        countries: %w[barbados costa-rica cuba dominican-republic jamaica trinidad-and-tobago],
        name: 'Caribbean' },
      { slug: 'central_and_eastern_europe',
        countries: %w[bosnia-and-herzegovina bulgaria croatia czech-republic hungary macedonia poland romania serbia slovakia slovenia],
        name: 'Central and Eastern Europe' },
      { slug: 'china',
        countries: %w[china],
        name: 'China' },
      { slug: 'south_america',
        countries: %w[argentina bolivia brazil chile colombia ecuador guyana mexico panama peru uruguay venezuela],
        name: 'South America' },
      { slug: 'mediterranean_europe',
        countries: %w[cyprus greece israel italy portugal spain],
        name: 'Mediterranean Europe' },
      { slug: 'middle_east',
        countries: %w[afghanistan bahrain iran iraq jordan kuwait lebanon oman pakistan palestine qatar saudi-arabia the-united-arab-emirates],
        name: 'Middle East' },
      { slug: 'nordic_and_baltic',
        countries: %w[denmark estonia finland iceland latvia lithuania norway sweden],
        name: 'Nordic & Baltic' },
      { slug: 'north_africa',
        countries: %w[algeria egypt libya morocco tunisia],
        name: 'North Africa' },
      { slug: 'north_america',
        countries: %w[canada the-usa],
        name: 'North America' },
      { slug: 'north_east_asia',
        countries: %w[japan japan south-korea taiwan],
        name: 'North East Asia' },
      { slug: 'south_asia',
        countries: %w[bangladesh india nepal sri-lanka],
        name: 'South Asia' },
      { slug: 'south_east_asia',
        countries: %w[brunei burma cambodia indonesia malaysia philippines singapore thailand vietnam],
        name: 'South East Asia' },
      { slug: 'sub_saharan_africa',
        countries: %w[angola cameroon ethiopia ghana ivory-coast kenya mauritius mozambique namibia nigeria rwanda senegal seychelles south-africa tanzania uganda zambia],
        name: 'Sub Saharan Africa' },
      { slug: 'turkey_russia_and_caucasus',
        countries: %w[armenia azerbaijan georgia kazakhstan mongolia russia tajikistan turkey turkmenistan ukraine uzbekistan],
        name: 'Turkey, Russia & Caucasus' },
      { slug: 'western_europe',
        countries: %w[austria belgium france germany ireland luxembourg netherlands switzerland],
        name: 'Western Europe' },
  ].sort_by { |region| region[:name] }
end



