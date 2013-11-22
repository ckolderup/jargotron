class Category
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :category_query_fmt, String
  property :created_at, DateTime

  has n, :topics
  has n, :property
  has n, :category_attempt
end

