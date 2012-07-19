# CfgSetTest.l.rb
#
gem 'minitest'

require 'lib/CfgSet'
require 'minitest/spec'
require 'minitest/autorun'

include CfgSet

TestDir = "#{ENV['SpotTestOutputDir']}"

describe CfgSet do

	it "should be a module" do
		CfgSet.must_be_instance_of Module
	end

	describe "DirectoryBase" do

		it "should be a class" do
			DirectoryBase.must_be_instance_of Class
		end

	end

	describe "Probe" do
		it "should be a class" do
			Probe.new('nodename','/tmp').must_be_instance_of DirectoryBase
		end
	end

	describe "AdhocBattery" do
	end

	describe "Battery" do
	end

	describe "AdminBattery" do
	end

	describe "AdhocTests" do
	end

	describe "Tests" do
	end

end

# End of CfgSetTest.l.rb
