task :environment do
  require_relative 'jargotron'
end

desc "Creates a new topic"
task :new_topic, [:name] => [:environment] do |t, args|
  topic = Topic.create(name: args[:name], created_at: Time.now)
  topic.save!
end

desc "Creates a new category"
task :new_category, [:name] => [:environment] do |t, args|
  category = Category.new(name: args[:name],
                             created_at: Time.now,
                             category_query_fmt: "Is %%topic%% #{args[:name]}?")
  unless category.save
    category.errors.each { |e| puts e }
  end
end

desc "Creates a new property"
task :new_property, [:name,:category_id] => [:environment] do |t, args|
  property = Property.create(name: args[:name],
                             created_at: DateTime.now,
                             category: Category.get(args[:category_id]),
                             property_query_fmt: "Is %%topic%% #{args[:name]}?")
  unless property.save
    property.errors.each { |e| puts e }
  end
end

desc "Creates a new joke"
task :new_joke, [:joke_fmt,:property_id] => [:environment] do |t, args|
  joke = Joke.create(created_at: DateTime.now,
                     property: Property.get(args[:property_id]),
                     joke_fmt: args[:joke_fmt])
  unless joke.save
    joke.errors.each { |e| puts e }
  end
end

desc "Lists topics"
task :topics => :environment do
  Topic.all.each { |t| puts t.name }
end

desc "Lists properties"
task :properties => :environment do
  Property.all.each { |p| puts "#{p.id} #{p.name} (#{p.category.name})" }
end

desc "Lists categories"
task :categories => :environment do
  Category.all.each { |c| puts "#{c.id} #{c.name}" }
end

desc "List jokes"
task :jokes => :environment do
  Joke.all.each { |j| puts "#{j.id} #{j.joke_fmt}" }
end

desc "List properties that don't have jokes assigned"
task :jokeless_properties => :environment do
  props = Property.all.to_set - Joke.all.map{ |j| j.property }.uniq.to_set
  props.each  { |p| puts "#{p.id} #{p.name} (#{p.category.name})" }
end

desc "Delete a property by its id"
task :delete_property, [:property_id] => [:environment] do |t, args|
  Property.get(args[:property_id]).destroy!
end

desc "Print a joke"
task :print_joke => :environment do
  puts Jargotron.write_joke
end

desc "Finds topics that have properties"
task :finished_topics => :environment do
  Topic.all.reject { |t| t.property.nil? }.map {|x| puts "#{x.name} => #{x.property.name}"}
end

desc "Finds topics that aren't finished yet"
task :unfinished_topics => :environment do
  Topic.all.select { |t| t.property.nil? || t.category.nil? }.map {|x| puts "#{x.name}" + (x.category.nil? ? "" : "(is #{x.category.name})")}
end

Dir.glob('lib/tasks/*.rake').each { |r| import r }
