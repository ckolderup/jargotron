require 'dm-core'
require 'dm-migrations'
require 'dm-validations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/database.db")

require_relative 'topic'
require_relative 'category'
require_relative 'property'
require_relative 'category_attempt'
require_relative 'property_attempt'
require_relative 'joke'

DataMapper.auto_upgrade!
