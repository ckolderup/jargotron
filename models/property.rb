class Property
  include DataMapper::Resource
  property :id, Serial
  property :name, String, length: 140
  property :property_query_fmt, String, length: 140
  property :created_at, DateTime

  belongs_to :category, required: false
  has n, :topic
  belongs_to :property_attempt, required: false
end
