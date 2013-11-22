class PropertyAttempt
  include DataMapper::Resource
  property :id, Serial
  property :tweet_id, String
  property :created_at, DateTime, :default => lambda { |p,s| DateTime.now }

  belongs_to :topic, required: false
  belongs_to :property, required: false

  def question_string(q_topic)
    property.property_query_fmt.gsub("%%topic%%", q_topic.name)
  end
end
