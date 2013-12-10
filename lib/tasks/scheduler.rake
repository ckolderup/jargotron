desc "Tweets a random question"
task :tweet_question => :environment do
  Jargotron.tweet_question
end

desc "Checks Twitter to settle last question"
task :collate_replies => :environment do
  Jargotron.collate_replies
end

desc "Tweets a random joke"
task :tweet_joke => :environment do
  Jargotron.tweet_joke
end
