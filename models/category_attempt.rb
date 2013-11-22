class CategoryAttempt
  include DataMapper::Resource
  property :id, Serial
  property :tweet_id, String
  property :created_at, DateTime, :default => lambda {|p,s| DateTime.now }

  belongs_to :topic, required: false
  belongs_to :category, required: false

  def question_string(q_topic)
    category.category_query_fmt.gsub("%%topic%%", q_topic.name)
  end
end
