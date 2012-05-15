#!/usr/bin/ruby

require 'uri'

puts "trace 0"

mo = URI.parse('http://hostname')

puts "trace 1:  #{mo.host}"

