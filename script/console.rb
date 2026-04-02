#!/usr/bin/env ruby

require_relative '../config/boot'
require 'pry'

# initialize DB connection
db = db_checkout

puts 'Console loaded'
puts "DB connected: #{db.inspect}"

binding.pry
