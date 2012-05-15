#!/usr/bin/ruby

puts "trace 0"

require 'SSKit.rb'

puts "trace 1"

include SSKit

puts "trace 2"

ssko = SSClass.new

puts "trace 3"

