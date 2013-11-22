class Topic
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :created_at, DateTime

  belongs_to :category, required: false
  belongs_to :property, required: false
  has n, :property_attempt
  has n, :category_attempt
end
