#!/usr/bin/env ruby

require 'pry'
require_relative '../db/connection'

# initialize DB connection
db = db_checkout

puts 'Console loaded'
puts "DB connected: #{db.inspect}"

binding.pry
