#!/usr/bin/ruby

require 'uri'
require 'ProbeKit.rb'

puts "trace 0"
include ProbeKit
puts "trace 1"
validateAbsSpec('/tmp')
puts "trace 2"
puts "trace 3"
puts "trace 4"
puts "trace 5"

