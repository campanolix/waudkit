#!/usr/bin/ruby

puts "trace 0"

require 'ProbeKit.rb'

puts "trace 1"

include ProbeKit

puts "trace 2"

to = CurlHTTPCfg.new('/tmp')

puts "trace 3"

