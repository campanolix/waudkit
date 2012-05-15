# ProbeKitTest.b.rb
#
gem 'minitest'

require 'lib/ProbeKit'
require 'minitest/spec'
require 'minitest/autorun'

include ProbeKit

TestDir = "#{ENV['SpotTestOutputDir']}"

describe ProbeKit do

	describe "CurlHTTP bugs that should not recur include:" do
	end

	describe "PingICMP bugs that should not recur include:" do
	end

	describe "ProbeSequence bugs that should not recur include:" do
	end

	describe "TestBattery bugs that should not recur include:" do
	end

	describe "ProbeTestList bugs that should not recur include:" do
	end

end

# End of ProbeKitTest.b.rb
