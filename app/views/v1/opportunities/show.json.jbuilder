if @result
  json.opportunity do
    json.partial! 'v1/opportunity', record: @result.data
  end
end
