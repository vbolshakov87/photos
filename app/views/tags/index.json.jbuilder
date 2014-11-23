json.array!(@tags) do |tag|
  json.extract! tag, :id, :title, :count
  json.url tag_url(tag, format: :json)
end
