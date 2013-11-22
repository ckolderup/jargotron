class Joke
  include DataMapper::Resource
  property :id, Serial
  property :joke_fmt, String, length: 140
  property :created_at, DateTime

  belongs_to :topic, required: false
  belongs_to :property, required: false

  def finish(j_topic)
    joke_fmt.gsub("%%topic%%", j_topic.name)
  end
end
