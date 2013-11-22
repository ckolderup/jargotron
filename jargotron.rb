require 'sinatra'
require_relative 'twitter_setup'
require_relative 'models/init'

class Jargotron
  def self.write_joke
    topic = Topic.all.select { |t| !t.property.nil? }.sample
    puts "chose #{topic.name}"
    joke = Joke.all.select { |j| j.property == topic.property}.sample
    puts "chose #{joke.joke_fmt}"

    joke.finish unless joke.nil?
  end

  def self.tweet_question
    if (Random.new.rand(1..10) < 3) then
      tweet_property_q
    else
      tweet_category_q
    end
  end

  def self.tweet_property_q
    topic = Topic.all.select { |t| !t.category.nil? && t.property.nil? }.sample
    puts "chose #{topic.name}"
    property = Property.all.select { |p| p.category == topic.category }.sample
    if property.nil? then
      tweet_category_q
    else
      puts "chose #{property.name}"
      question = property.property_query_fmt.gsub("%%topic%%", topic.name)

      tweet = Twitter.update(question)
      attempt = PropertyAttempt.new(id: tweet.id, topic: topic, property: property)
      attempt.save!
    end
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

    if ( property_attempt.nil? || category_attempt.created_at > property_attempt.created_at) then
      if reply_helper(category_attempt) then
        category_attempt.topic.category = category_attempt.category
        category_attempt.topic.save!
        Twitter.update("wow, okay! Sounds like #{category_attempt.topic.name} is #{category_attempt.category.name}!")
      else
        Twitter.update("hmm, maybe #{category_attempt.topic.name} isn't #{category_attempt.category.name}...")
      end
      category_attempt.destroy!
    else
      if reply_helper(property_attempt) then
        property_attempt.topic.property = property_attempt.property
        property_attempt.topic.save!
        Twitter.update("wow, okay! Sounds like #{property_attempt.topic.name} is #{property_attempt.property.name}!")
      else
        Twitter.update("hmm, maybe #{property_attempt.topic.name} isn't #{property_attempt.property.name}...")
      end
    end
  end

  def self.reply_helper(attempt)
    replies = Twitter.mentions_timeline
    relevant = replies.select do |tweet|
      tweet.in_reply_to_status_id == attempt.id
    end

    yeses = relevant.select do |t|
      t.text.match(/^@#{Twitter.user.screen_name} y(.*?)$/)
    end

    nos = relevant.select do |t|
      t.text.match(/^@#{Twitter.user.screen_name} n(.*?)/)
    end

    puts "asked: #{attempt.question_string(attempt.topic)}"
    yeses.size >= nos.size
  end
end
