
module CfgSet

=begin
	Note:  For the purposes of configurations, we have the following hierarchy:

		Probes - represents a single probe, but containing all the addresses for a
			probe step to be used in a TestBattery.

		AdHocBattery - represents all the steps for all the parallel probes for a test.
			Note also that this is a container class for Probes.

		Battery < AdHocTestCfg - Contains all the maintenance configurations for
			ongoing probing.  Note that this contains all the same data as TestBattery
			in ProbeKit, but the organization is different to accommodate better
			maintenance of the configurations.
		
		ProbeTests - A container class for Battery objects which also has generally
			applicable configurations.

		AdminTests < ProbeTests - for holding extra supporting data like raw
			state items for use in maintaining the configurations more fluidly.
=end
	

	class Probe
		attr_reader :Timeout, :URLList, :Validations
	end

	class AdHocBattery

		def initialize
			@SequenceSet = Array.new
		end

	end

	class Battery < AdHocBattery
		attr_reader :Label, :MinSitings4Failure, :ProbeSetPeriod

	end

	class AdminBattery < Battery
		attr_reader :RawDataFiles, :CompileScripts

	end

	class Tests
		# Cfg organized version of ProbeKit::TestList

		def initialize
			@Batteries = Array.new
		end

	end

end # End of CfgSet module
