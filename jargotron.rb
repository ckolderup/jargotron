require 'andand'
require 'sentimental'
require_relative 'twitter_setup'
require_relative 'models/init'

class Jargotron
  def self.write_joke
    topic = Topic.all.select { |t| !t.property.nil? }.sample
    puts "chose #{topic.name}"
    joke = Joke.all.select { |j| j.property == topic.property}.sample
    puts "chose #{joke.joke_fmt}"

    joke.finish(topic) unless joke.nil?
  end

  def self.tweet_joke
    joke = write_joke

    Twitter.update(joke) unless joke.nil?
  end

  def self.tweet_question
    uncategorized_left = Topic.all.select { |t| t.category.nil? }.size
    unfinished_left = Topic.all.select { |t| t.property.nil? }.size

    if (Random.new.rand(1..10) < 3 || uncategorized_left == 0) then
      tweet_property_q
    else
      tweet_category_q
    end

    on_empty = ["I need more topics!", "Help me find more to learn about?", "What should I study next?",
                "Where do we go from here?", "Feels like I know everything about everything..."]

    Twitter.update("@ckolderup #{on_empty.sample}") if unfinished_left < 5
  end

  def self.tweet_property_q
    topic = Topic.all.select { |t| !t.category.nil? && t.property.nil? }.sample
    puts "chose #{topic.name}"
    property = Property.all.select { |p| p.category == topic.category }.sample

    puts "chose #{property.name}"
    question = property.property_query_fmt.gsub("%%topic%%", topic.name)

    tweet = Twitter.update(question)
    attempt = PropertyAttempt.new(id: tweet.id, topic: topic, property: property)
    attempt.save!
  end

  def self.tweet_category_q
      topic = Topic.all.select { |t| t.category.nil? }.sample
      puts "chose #{topic.name}"
      category = Category.all.sample
      puts "chose #{category.name}"

      question = category.category_query_fmt.gsub("%%topic%%", topic.name)

      tweet = Twitter.update(question)
      attempt = CategoryAttempt.new(id: tweet.id, topic: topic, category: category)
      attempt.save!
  end

  def self.collate_replies
    category_attempt = CategoryAttempt.last(order: [:id.asc])
    property_attempt = PropertyAttempt.last(order: [:id.asc])

    last_category_attempt_stamp = category_attempt.andand.created_at.to_time.to_i
    last_property_attempt_stamp = property_attempt.andand.created_at.to_time.to_i

    confirmation_prefixes = [ "wow, okay! Sounds like", "Thanks, everyone!", "Cool! I guess"]
    unsure_prefixes = ["hmm, maybe", "alright, so apparently", "ugh, looks like"]

    if ( last_category_attempt_stamp > last_property_attempt_stamp) then
      if reply_helper(category_attempt) then
        category_attempt.topic.category = category_attempt.category
        category_attempt.topic.save!
        Twitter.update("#{confirmation_prefixes.sample} #{category_attempt.topic.name} is #{category_attempt.category.name}!")
      else
        Twitter.update("#{unsure_prefixes.sample} #{category_attempt.topic.name} isn't #{category_attempt.category.name}...")
      end
      category_attempt.destroy!
    else
      if reply_helper(property_attempt) then
        property_attempt.topic.property = property_attempt.property
        property_attempt.topic.save!
        Twitter.update("#{confirmation_prefixes.sample} #{property_attempt.topic.name} is #{property_attempt.property.name}!")
      else
        Twitter.update("#{unsure_prefixes.sample} #{property_attempt.topic.name} isn't #{property_attempt.property.name}...")
      end
      property_attempt.destroy!
    end
  end

  def self.reply_helper(attempt)
    replies = Twitter.mentions_timeline(count: 200)
    relevant = replies.select do |tweet|
      tweet.in_reply_to_status_id == attempt.id
    end

    Sentimental.load_defaults
    Sentimental.load_senti_file('./answers.txt')
    Sentimental.threshold = 0.1
    analyzer = Sentimental.new

    yeses = relevant.select do |t|
      analyzer.get_sentiment(t.text) == :positive
    end

    nos = relevant.select do |t|
      analyzer.get_sentiment(t.text) == :negative
    end

    puts "asked: #{attempt.question_string(attempt.topic)}"
    yeses.size >= nos.size && yeses.size > 0
  end
end
