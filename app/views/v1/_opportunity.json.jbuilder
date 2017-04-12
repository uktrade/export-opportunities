json.id                       record.id
json.title                    record.title
json.slug                     record.slug
json.created_at               format_datetime(record.created_at)
json.updated_at               format_datetime(record.updated_at)
json.status                   record.status
json.teaser                   record.teaser
json.response_due_on          format_date(record.response_due_on)
json.description              record.description
json.service_provider         record.service_provider.name

json.contacts do
  json.array!(@result.data.contacts) do |contact|
    json.partial! 'v1/contact', record: contact
  end
end

json.countries do
  json.array!(@result.data.countries) do |country|
    json.partial! 'v1/country', record: country
  end
end

json.sectors do
  json.array!(@result.data.sectors) do |sector|
    json.partial! 'v1/sector', record: sector
  end
end

json.types do
  json.array!(@result.data.types) do |type|
    json.partial! 'v1/type', record: type
  end
end

json.values do
  json.array!(@result.data.values) do |value|
    json.partial! 'v1/value', record: value
  end
end
