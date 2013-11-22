desc "Print a random example question"
task :print_question => :environment do
  puts Jargotron.make_proposal
end

desc "Tweets a random question"
task :tweet_question => :environment do
  Jargotron.tweet_question
end

desc "Checks Twitter to settle last question"
task :collate_replies => :environment do
  Jargotron.collate_replies
end
