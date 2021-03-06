
module CfgSet

=begin
Note:  For the purposes of configurations, we have the following hierarchy:

		Probe - represents a single probe, but containing all the addresses for a
			probe step to be used in a TestBattery.

		AdHocBattery - represents all the steps for all the parallel probes for a test.
			Note also that this is a container class for Probes.

		Battery < AdHocTestCfg - Contains all the maintenance configurations for
			ongoing probing.  Note that this contains all the same data as TestBattery
			in ProbeKit, but the organization is different to accommodate better
			maintenance of the configurations.
		
		AdminBattery < Battery - For all the extra configurations needed for administration
			and reporting with ongoing test probes.

		AdhocTests - A container class for Battery objects which also has generally
			applicable configurations.

		Tests < AdhocTests - For general use in ongoing production activities.

=end
	
# # # # Begin Internal Classes

#        01234567890123456789012345678901234567890123456789012345678901234567890
		# Module Utility Methods
		
	def validateAndStripAbsSpec(dirStr,methStr)
		unless dirStr and dirStr.class == String and dirStr.length > 2
			raise ArgumentError,
			"Invalid #{self.class}  directory argument '#{dirStr}' in methStr."
		end
		lds = dirStr.strip
		unless lds =~ /^\/\S\S+/
			raise ArgumentError,
				"Invalid #{self.class}  directory argument '#{lds}' in methStr."
		end
		return lds
	end

	def validateAndStripURL(sURI,methStr)
		unless sURI and sURI.class == String
			raise ArgumentError,
				"Invalid #{self.class} sURI argument '#{sURI}' in #{methStr} method."
		end
		lurl = sURI.strip
		unless lurl =~ /^https?:\/\/\S\S+$/
			raise ArgumentError,
				"Invalid #{self.class} sURI argument '#{lurl}' in #{methStr} method."
		end
		return lurl
	end

	def validateChannel(chStr,methStr)
		validateStringObject(chStr,methStr,5)
		return if chStr == Channel0
		return if chStr == Channel1
		return if chStr == Channel2
		raise ArgumentError,
	"Invalid #{self.class} chStr argument '#{chStr}' in #{methStr} method."
	end

	def validateFixnum(fixNum,methStr)
		return if fixNum and fixNum.class == Fixnum
		raise ArgumentError,
			"Invalid #{self.class} fixNum argument '#{fixNum}' in #{methStr} method."
	end

	def validateStringObject(aStr,methStr,minLen=0)
		unless aStr and aStr.class == String
			raise ArgumentError,
				"Invalid:  #{methStr} #{aStr} must be a String."
		end
		unless minLen.class == Fixnum
			raise ArgumentError, "Invalid minLen specified."
		end
		unless aStr.length >= minLen
			raise ArgumentError,
"Invalid String Length:  #{methStr} #{aStr} must be at least length #{minLen}."
		end
	end

	def validateTimeObject(tO,methStr)
		unless tO and tO.class == Time
			raise ArgumentError,
				"Invalid #{self.class} tO argument '#{tO}' in #{methStr} method."
		end
	end

	def zFill2DigitWholeNo(nN)
		validateFixnum(nN,"zFill2DigitWholeNo(nN)")
		if nN < 0
			raise ArgumentError, "Invalid two digit whole number #{nN} < 0."
		end
		if nN > 99
			raise ArgumentError, "Invalid two digit whole number #{nN} > 99."
		end
		return   "#{nN}" if nN > 9
		return  "0#{nN}"
	end

	def zFill3DigitWholeNo(nN)
		validateFixnum(nN,"zFill3DigitWholeNo(nN)")
		if nN < 0
			raise ArgumentError, "Invalid three digit whole number #{nN} < 0."
		end
		if nN > 999
			raise ArgumentError, "Invalid three digit whole number #{nN} > 999."
		end
		return   "#{nN}" if nN > 99
		return  "0#{nN}" if nN > 9
		return "00#{nN}"
	end

	def zFill5DigitWholeNo(nN)
		validateFixnum(nN,"zFill5DigitWholeNo(nN)")
		if nN < 0
			raise ArgumentError, "Invalid five digit whole number #{nN} < 0."
		end
		if nN > 99999
			raise ArgumentError, "Invalid five digit whole number #{nN} > 999."
		end
		return   "#{nN}" if nN > 9999
		return   "0#{nN}" if nN > 999
		return   "00#{nN}" if nN > 99
		return  "000#{nN}" if nN > 9
		return "0000#{nN}"
	end

	def zFillMonthDay(mDay)
		validateFixnum(mDay,"zFillMonthDay(mDay)")
		if mDay < 1
			raise ArgumentError, "Invalid Month Day #{mDay} < 1."
		end
		if mDay > 31
			raise ArgumentError, "Invalid Month Day #{mDay} > 31."
		end
		result = zFill2DigitWholeNo(mDay)
		return result
	end

	def zFillMonthNo(mNo)
		validateFixnum(mNo,"zFillMonthNo(mNo)")
		if mNo < 1
			raise ArgumentError, "Invalid Month Number #{mNo} < 1."
		end
		if mNo > 12
			raise ArgumentError, "Invalid Month Number #{mNo} > 12."
		end
		result = zFill2DigitWholeNo(mNo)
		return result
	end

	def zFillSixtieth(sxNo)
		validateFixnum(sxNo,"zFillSixtieth(sxNo)")
		if sxNo < 0
			raise ArgumentError, "Invalid sixtieth number #{sxNo} < 0."
		end
		if sxNo >= 60
			raise ArgumentError, "Invalid sixtieth number #{sxNo} >= 60."
		end
		nostr = zFill2DigitWholeNo(sxNo)
		return nostr
	end

	def zFillTwentyFourth(tfNo)
		validateFixnum(tfNo,"zFillTwentyFourth(tfNo)")
		if tfNo < 0
			raise ArgumentError, "Invalid twentyfourth number #{tfNo} < 0."
		end
		if tfNo >= 24
			raise ArgumentError, "Invalid twentyfourth number #{tfNo} >= 24."
		end
		nostr = zFill2DigitWholeNo(tfNo)
		return nostr
	end


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
#	Stand alone configuration classes (for little pieces)
#

class AddressBase

	attr_reader :AddrStr, :AddrO
	
	# Add method for default interpolation assignment in strings of @AddrStr.

	def initialize(addrStr)
		unless addrStr
			raise ArgumentError, "nil Address String Invalid."
		end
		addrStr.strip!
		if addrStr.length < 2 then
			raise ArgumentError, "Address String '#{addrStr}' Too Short."
		end
		@AddrO = addrStr
		@AddrStr = addrStr
	end

end

class HostName < AddressBase

	def initialize(addrStr)
		super(addrStr)
		unless @AddrStr =~ /^\w{2,32}$/
			raise ArgumentError, "Hostname String '#{@AddrStr}' has invalid characters."
		end
	end

end

class HexAddress < AddressBase

	def initialize(addrStr)
		super(addrStr)
		unless @AddrStr =~ /^\x{1,32}$/
			raise ArgumentError, "Hex Address String '#{addrStr}' has invalid characters."
		end
		# Add assignment of integer to @AddrO
	end

end

class IPAddress < AddressBase

	def initialize(addrStr)
		super(addrStr)
		unless @AddrStr =~ /^[12]?\o{1,2}\.[12]?\o{1,2}\.[12]?\o{1,2}\.[12]?\o{1,2}$/
			raise ArgumentError, "IP Address '#{@AddrStr}' has invalid format."
		end
		# Add assignment of integer to @AddrO
	end

end

class URL < AddressBase

	def initialize(addrStr)
		super(addrStr)
		unless @AddrStr =~ /^http/
			raise ArgumentError, "URL does not begin with http prefix string."
		end
		@AddrO = URI.new(addrStr)
	end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
#	Configuration Classes for loading, validating, and conveying flat file data.
#	The first few are base classes.
#

class Base_FlatCfg

	attr_accessor :Value
	attr_reader :CfgSpec, :Label

	protected

	def assignValueIfValid
		@Value = @LoadString
	end

	def parseCfg
		unless File.exists?(@CfgSpec)
			if @EmptyOkay then
				return false
			else
				raise LoadError,
			"Required #{@Label} CfgSpec #{@CfgSpec} does not exist."
			end
		end
		@LoadString = FlatTools.getFile(@CfgSpec).chomp
		unless @LoadString and @LoadString.class == String
			raise LoadError, "Invalid @LoadString #{@LoadString}."
		end
		return true
	end

	def parseAndValidate
		validateMiscellany
		if parseCfg then
			assignValueIfValid
		end
	end

	def validateMiscellany
		unless @CfgDir and @CfgDir.class == String and @CfgDir.length >= 1 && @CfgDir =~ /^\S+/
			raise LoadError, "Invalid @CfgSpec #{@CfgSpec}."
		end
		unless @CfgName and @CfgName.class == String and @CfgName.length >= 2 && @CfgName =~ /^\S+/
			raise LoadError, "Invalid @CfgName #{@CfgName}."
		end
		unless @CfgSpec and @CfgSpec.class == String and @CfgSpec.length > 8 && @CfgSpec =~ /^\/\S+\//
			raise LoadError, "Invalid @CfgSpec #{@CfgSpec}."
		end
		unless @Label and @Label.class == String
			raise LoadError, "Invalid @Label #{@Label}."
		end
	end

	public

	def initialize(cfgDir)
		@CfgDir = validateAndStripAbsSpec(cfgDir,'SpotFlatCfg instantiator')
		@CfgName = self.class.to_s.sub(/^\S+::/,'')
		@CfgSpec = "#{@CfgDir}/#{@CfgName}"
		parseAndValidate
	end

#        01234567890123456789012345678901234567890123456789012345678901234567890
	# Object Interface Methods

	def cfgExists?
		return true if File.exists?(@CfgSpec)
		return false
	end
	
	def dumpAsHTML
		return CGI.escapeHTML("#{@Value}")
	end

	def dumpAsString
		return "#{@Value}"
	end

end

class L2Abstract_FlatListCfg < Base_FlatCfg

	attr_reader :MaxLines, :MinLines

	protected

	def assignValueIfValid
		# Nothing done here, as assignments re in parseCfg
	end

	def handleMissingFile
		unless @EmptyOkay 
			# Then Presume required unless a specific method is defined.
			raise LoadError,
				"Required #{@Label} configuration #{@CfgSpec} is not present."
		end
	end

	def parseCfg
		@Value = Array.new
		if File.exists?(@CfgSpec)
			@LoadString = FlatTools.getFile(@CfgSpec)
			@LoadString.each_line do |line|
				l = line.chomp
				validateLine(l)
				@Value.push(l)
			end
			unless @MinLines <= @Value.length and @Value.length <= @MaxLines
				raise ArgumentError, "#{@Label} Lines count #{@Value.length}" +
			" in #{@CfgSpec} is outside of range (#{@MinLines},#{@MaxLines})"
			end
		else
			handleMissingFile
		end
	end

	def validateMiscellany
		super
		validateFixnum(@MinLines,'validateMiscellany')
		validateFixnum(@MaxLines,'validateMiscellany')
	end

	def validateLine(lStr)
		unless lStr.length > 0
			raise ArgumentError, "Invalid #{@Label} Line zero length!"
		end
	end

	public

#        01234567890123456789012345678901234567890123456789012345678901234567890
	# Object Interface Methods
	
	def dumpAsString
		markup = ""
		@Value.each do |line|
			markup += "#{line}<br />\n"
		end
		return markup
	end

end

class L2Abstract_SingleLineTextCfg < Base_FlatCfg

	protected

	def validateSingleLineText
		unless @LoadString and @LoadString.class == String and @LoadString.length > 0
			raise ArgumentError, "Missing or Invalid LoadString in Single Line Text Cfg Object #{@CfgSpec}."
		end
		ll = @LoadString.split("\n").length
		if ll > 1 then 
			raise ArgumentError,
"Multi-line string invalid for #{@CfgSpec} #{self.class} configuration."
		elsif ll < 1 then 
			raise ArgumentError,
"Some Invalid string state (#{@LoadString}) for #{@CfgSpec} #{self.class} configuration."
		end
	end

	def parseCfg
		super
		validateSingleLineText unless @EmptyOkay and not cfgExists?
	end

end

class L2Abstract_SpecOnlyCfg < BaseFlatCfg

	protected

	def parseCfg
		# Empty is always a valid option for SpecOnly, since missing files indicate the function is just not in use.
		@EmptyOkay = true
		if File.exists?(@CfgSpec) then
			@LoadString = "Data NOT loaded at instantiation.  Access by @CfgSpec."
		else
			@LoadString = nil
		end
	end

end

class L3Abstract_BooleanCfg < L2Abstract_SingleLineTextCfg

	protected

	def assignValueIfValid
		# Nothing done here, as assignments re in parseCfg
	end

	def parseCfg
		# Empty is always a valid false option with this kind of configuration.  If the configuration file
		# is omitted, the value is false.  Therefore @EmptyOkay is always true.
		@EmptyOkay = true
		if File.exists?(@CfgSpec)
			@LoadString = FlatTools.getFile(@CfgSpec).strip
			validateSingleLineText
			if @LoadString.upcase =~ /TRUE/ then
				@Value = true
			elsif @LoadString.upcase =~ /FALSE/ then
				@Value = false
			else
				raise ArgumentError, "Invalid #{@Label} in #{@CfgSpec}.  Must be TRUE or FALSE.  Was #{@LoadString}."
			end
		else
			@Value = false
		end
	end

end

class L3Abstract_EmailList < L2Abstract_FlatListCfg

	def SpotEmailList.validate(elO)
		# Easiest way to do this now, but there may be a better way:
		return true if elO.ancestors.rindex(SpotEmailList)
		return false
	end

	protected

	def validateLine(lStr)
		unless lStr =~ /^\s*\w{2,32}@\w+\S+\s*$/
			raise SyntaxError, "Invalid email address in #{@Label}"
		end
	end

	def initialize(cfgDir)
		super(cfgDir)
		unless SpotEmailList.validate(self)
			raise LoadError, "FATAL Programmer Error:  #{self.class} is not seen as a descendent of SpotEmailList."
		end
	end

end

class L3Abstract_TestList < L2Abstract_FlatListCfg

	# Broken from legacy references

	protected

	def validateLine(lStr)
		#Below is broken, as SpotService does not exist now:
		SpotService.validateServiceId(lStr,'TestList validateLine(lStr)')
		dspec = "#{@ServicesCfgDir}/#{lStr}"
		unless File.exists?(dspec)
			raise ArgumentError,
	"Directory '#{dspec}' for Service List Id #{lStr} in #{@Label} not found."
		end
	end

	public

	def initialize(cfgDir)
		@CfgDir = validateAndStripAbsSpec(cfgDir,'TestList instantiator')
		@CfgName = self.class.to_s.sub(/^\S+::/,'')
		@CfgSpec = "#{@CfgDir}/#{@CfgName}"
		@ServicesCfgDir = "#{@CfgDir}/services"
		# This object can never be empty, so @EmptyOkay must always be false.
		@EmptyOkay = false
		parseAndValidate
	end

end

class L3Abstract_WholeNoCfg < L2Abstract_SingleLineTextCfg

	attr_reader :Maximum, :Minimum

	protected

	def assignValueIfValid
		unless @LoadString =~ /^\d+$/
			raise ArgumentError,
"Invalid #{@Label} in #{@CfgSpec}.  Must be a positive integer."
		end
		@Value = @LoadString.to_i
		unless @Minimum <= @Value and @Value <= @Maximum
			raise ArgumentError,
"Invalid #{@Label}(#{self.class}) value #{@Value} out of range {#{@Minimum},#{@Maximum}}."
		end
	end

	def validateMiscellany
		super
		validateFixnum(@Minimum,'validateMiscellany')
		validateFixnum(@Maximum,'validateMiscellany')
	end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
#	Concrete Configuration Classes.
#

class AdminEmailList < L3Abstract_EmailList

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Spot Administration Email List'
		@MinLines = 1
		@MaxLines = 16
		super(cfgDir)
	end

end

class AllDataExpirationMinutes < L3Abstract_WholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'All Data Expiration Minutes'
		@Minimum = MinMinuteHistoryRange
		@Maximum = MaxMinuteHistoryRange
		super(cfgDir)
	end

end

class AppTrace < L3Abstract_BooleanCfg

	public

	def initialize(cfgDir)
		@Label = 'Turn on Any App Specific Traces of Addresses probed.'
		super(cfgDir)
	end

end


class BinaryPOSTData < L2Abstract_SpecOnlyCfg

	public

	def initialize(cfgDir)
		@Label = 'Service Binary POST Data'
		super(cfgDir)
	end

#        01234567890123456789012345678901234567890123456789012345678901234567890
	# Object Interface Methods
	
	def dumpAsHTML
		return "File is Binary:  Not dumped here."
	end

	def dumpAsString
		return "File is Binary:  Not dumped here."
	end

end

class BottomColumns < L3Abstract_WholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Bottom Service Report Columns'
		@Minimum = 1
		@Maximum = 9
		super(cfgDir)
	end

end

class BottomHelp < L2Abstract_FlatListCfg

	public

	def initialize(cfgDir)
		@Label = 'Bottom Help Rows'
		@MinLines = 1
		@MaxLines = 4196
		super(cfgDir)
	end

end

class BottomTests < L3Abstract_TestList

	public

	def initialize(cfgDir)
		@Label = 'Bottom Test Batteries for Report'
		@MinLines = 0
		@MaxLines = 32
		super(cfgDir)
	end

end

class Cookies < L3Abstract_BooleanCfg

	def initialize(cfgDir)
		@Label = 'Cookies Collected and Referenced (boolean)'
		super(cfgDir)
	end

end

class CronProbePeriod < L3Abstract_WholeNoCfg

	# Must establish that 1 works, or 61, for that matter.  120, for instance, would be nice.
	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Submission Period Specified in Crontab'
		@Minimum = 1
		@Maximum = 59
		super(cfgDir)
	end

end

class CurlHTTPHeaders < L2Abstract_SingleLineTextCfg

	protected

	def assignIfValid
		if File.exists?(@CfgSpec)
			# Caution:  There may be other switches that get adopted, in
			# which case this validation will need to be modified

			# Note please that this is not a complete validation, but only a sanity check.  You can have
			# bad stuff in this cfg without it being discerned here at all.

			# It would be good to check the RFCs and Curl docs here to see if there is a maximum length string...xc
			if @LoadString =~ /\-H\s+\S+/ or @LoadString =~ /\-\-header\s+\S+/
				@Value = @LoadString
			else
				raise SyntaxError,
	"Invalid Curl HTTP Header string '#{@LoadString}'.  Must have -H str or --header str."
			end
		else
			@Value = ""
		end
	end

	public

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'Service Curl HTTP Header Switches'
		super(cfgDir)
	end

end

class DailyEmailList < L3Abstract_EmailList

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Daily Reporting List'
		@MinLines = 0
		@MaxLines = 128
		super(cfgDir)
	end

end

class DataCollectionTests < L3Abstract_TestList

	public

	def initialize(cfgDir)
		@Label = 'Data Collection Test List.'
		@MinLines = 0
		@MaxLines = 32
		super(cfgDir)
	end

end

class EmailURL < L2Abstract_SingleLineTextCfg

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Hostname or DNS Name Representing an IP Address'
		super(cfgDir)
	end

end

class FailureRange < L3Abstract_WholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Failure Range'
		@Minimum = 5
		@Maximum = 30
		super(cfgDir)
	end

end

class FailureRangeStartOffset < L3Abstract_WholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Offset To Failure Range'
		@Minimum = 0
		@Maximum = 29
		super(cfgDir)
	end

end

class IgnoreStdout < L3Abstract_BooleanCfg

	def initialize(cfgDir)
		@Label = 'Ignore Stdout Data from Probe'
		super(cfgDir)
	end

end

class Label < L2Abstract_SingleLineTextCfg
	
	protected

	def assignIfValid
		unless @LoadString =~ /^.{3,64}$/
			raise SyntaxError, "Bad Label #{@LoadString}."
		end
		@Value = @LoadString
	end

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Service Label'
		super(cfgDir)
	end

end

class MinSitings4Failure < L3Abstract_WholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Service Specific Minimum Sitings for Failure'
		@Minimum = 1
		@Maximum = 8
		super(cfgDir)
	end

end

class MonthlyEmailList < L3Abstract_EmailList

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Monthly Reporting List'
		@MinLines = 0
		@MaxLines = 128
		super(cfgDir)
	end

end

class NotificationList < L3Abstract_EmailList
	# A feature to notify periodically and expire notifications is worth consideration.

	public

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'Failure Notification List'
		@MinLines = 0
		@MaxLines = 128
		super(cfgDir)
	end

end

class POSTData < L2Abstract_SpecOnlyCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'Service POST Data'
		super(cfgDir)
	end

#        01234567890123456789012345678901234567890123456789012345678901234567890
	# Object Interface Methods
	
	def dumpAsHTML
		value = dumpAsString
		return CGI.escapeHTML(value)
	end

	def dumpAsString
		value = ""
		if File.exists?(@CfgSpec)
			value = FlatTools.getFile(@CfgSpec)
		end
		return value
	end

end

class RefreshSeconds < L3Abstract_WholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Refresh Seconds'
		@Minimum = 15
		@Maximum = 300
		super(cfgDir)
	end

end

class ReNotificationPeriod < L3Abstract_WholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'Notification Minutes'
		@Minimum = 0
		@Maximum = 60
		super(cfgDir)
	end

end

class ReNotificationStartMinute < L3Abstract_WholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'Probe Start Minute in Hour'
		@Minimum = 0
		@Maximum = 59
		super(cfgDir)
	end

end

class StowProbeTimestamps < L3Abstract_BooleanCfg

	public

	# By default presumed to be turned on.
	def initialize(cfgDir)
		@Label = 'Collect and Stow Times for Steps in Probes.'
		super(cfgDir)
	end

end

class TestAppTimeout < L3Abstract_WholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Test Application Timeout'
		@Minimum = 1
		@Maximum = 300
		super(cfgDir)
	end

end

class TimeoutOverAppMax < L3Abstract_WholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Timeout Over Test App Max'
		@Minimum = 5
		@Maximum = 300
		super(cfgDir)
	end

end

class TopHelp < L2Abstract_FlatListCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'NavBar Function Help'
		@MinLines = 1
		@MaxLines = 4196
		super(cfgDir)
	end

end

class TopTests < L3Abstract_TestList

	public

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'Top Service Report Rows'
		@MinLines = 0
		@MaxLines = 9
		super(cfgDir)
	end

end

class TrackedProblemExpiration < L3Abstract_WholeNoCfg

	# This is for the amount of time past the present that a
	# tracked problem stays yellow.  After this period, a
	# tracked problem disappears and the status for that
	# server and service may then go back to green.

	public

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'Expiration Time for Tracked Problems.'
		@Minimum = 0
		@Maximum = 60
		super(cfgDir)
	end

end

class Validations < L2Abstract_FlatCfg

	attr_reader :ErrorNote

	protected

	def AdmonishNoStdout(cfgLine)
		raise LoadError,
"Stdout Validation '#{cfgLine}' Specified when Stdout Stowage Turned Off!"
	end

	def assignIfValid

		@Value = "Use method 'dumpAsString' to display cfg."

		@Strings	= Hash.new
		@Strings['Exist']	= Hash.new
		@Strings['NoFail']	= Hash.new

		@Strings['Exist']['stderr']		= Hash.new
		@Strings['Exist']['stdout']		= Hash.new
		@Strings['NoFail']['stderr']	= Hash.new
		@Strings['NoFail']['stdout']	= Hash.new

		@Strings['Exist']['stderr']['All']	= Array.new
		@Strings['Exist']['stdout']['All']	= Array.new
		@Strings['NoFail']['stderr']['All']	= Array.new
		@Strings['NoFail']['stdout']['All']	= Array.new

		@MinSize = Hash.new
		@MinSize['stderr'] = Hash.new
		@MinSize['stdout'] = Hash.new unless @IgnoreStdout

		@MinSize['stderr']['All'] = 0
		@MinSize['stdout']['All'] = 0 unless @IgnoreStdout

		if @LoadString and @LoadString.length > 0 then
			index = 0
			@LoadString.each_line do |line|
				next if line =~ /^\s*#/ or line =~ /^\s+$/
				lstr = line.chomp
				case lstr
				when /(\S+)\s+ExistString1:\s*(.*)$/
					AdmonishNoStdout(line) if @IgnoreStdout
					sstr = $1
					sstr = 'All' if sstr == 'all'
					unless @Strings['Exist']['stdout'].has_key?(sstr)
						@Strings['Exist']['stdout'][sstr] = Array.new
					end
					@Strings['Exist']['stdout'][sstr].push($2)
				when /(\S+)\s+ExistString2:\s*(.*)$/
					sstr = $1
					sstr = 'All' if sstr == 'all'
					unless @Strings['Exist']['stderr'].has_key?(sstr)
						@Strings['Exist']['stderr'][sstr] = Array.new
					end
					@Strings['Exist']['stderr'][sstr].push($2)
				when /(\S+)\s+FailString1:\s*(.*)$/
					AdmonishNoStdout(line) if @IgnoreStdout
					sstr = $1
					sstr = 'All' if sstr == 'all'
					unless @Strings['NoFail']['stdout'].has_key?(sstr)
						@Strings['NoFail']['stdout'][sstr] = Array.new
					end
					@Strings['NoFail']['stdout'][sstr].push($2)
				when /(\S+)\s+FailString2:\s*(.*)$/
					sstr = $1
					sstr = 'All' if sstr == 'all'
					unless @Strings['NoFail']['stderr'].has_key?(sstr)
						@Strings['NoFail']['stderr'][sstr] = Array.new
					end
					@Strings['NoFail']['stderr'][sstr].push($2)
				when /(\S+)\s+MinSize1:\s*(\d+)/
					AdmonishNoStdout(line) if @IgnoreStdout
					sstr = $1
					sstr = 'All' if sstr == 'all'
					nstr = $2
					@MinSize['stdout'][sstr] = nstr.to_i
				when /(\S+)\s+MinSize2:\s*(\d+)/
					sstr = $1
					sstr = 'All' if sstr == 'all'
					nstr = $2
					@MinSize['stderr'][sstr] = nstr.to_i
				else
					estr = "SpotService Validation Parse Error:  #{@CfgDir}."
					estr += "  INVALID line #{index} (|#{line}|)."
					raise SyntaxError, estr
				end
				index += 1
			end
		end

	end

	public

	def initialize(cfgDir,ignoreStdout)
		@EmptyOkay = false
		@IgnoreStdout = ignoreStdout
		@Label = 'Service Validations'
		super(cfgDir)
	end

#        01234567890123456789012345678901234567890123456789012345678901234567890
	# Object Interface Methods
	
	def dumpAsHTML
		markup = ""
		@LoadString.each_line do |line|
			markup += "#{CGI.escapeHTML(line.chomp)}<br />\n"
		end
		return markup
	end

	def dumpAsString
		markup = ""
		@LoadString.each_line do |line|
			markup += "#{line.chomp}<br />\n"
		end
		return markup
	end

	def hasServerFailure?(sprO)
		# This method has to separate out the data object as much as possible from the probe object.
		# I need to strive for a configuration oriented project that allies with, but is not strongly tied to 
		# the probe.
		ServerProbeRecord.validateObject(sprO,'hasServerFailure?(sprO)')

		unless sprO.StderrContent.length > 0 
			explanation = "No Stderr Diagnostics Saved from Probe"
			diagnostics = "sprO.StderrContent.length not positive."
			@ErrorNote = ErrorNote.new(sprO.ServerSpec,sprO.ServerURL,explanation,diagnostics)
			return true
		end

		unless sprO.StderrContent =~ /#{SuccessHTTPRegex}/
			explanation = "No 200 OK HTTP header found."
			diagnostics = "Primary Failure Type:  Missing HTTP 200 OK!\n" +
				"FAIL on Content2(#{sprO.ServerSpec}, " +
				"length #{sprO.StderrContent.length})) " +
				"match with SuccessHTTPRegex:  #{SuccessHTTPRegex}."
			@ErrorNote = ErrorNote.new(sprO.ServerSpec,sprO.ServerURL,explanation,diagnostics)
			return true
		end
		
		return true unless validateOverMinSize(sprO.StderrContent,'stderr',sprO.ServerSpec,sprO.ServerURL)

		return true unless validateStrings(sprO.StderrContent,'stderr',sprO.ServerSpec,'NoFail',sprO.ServerURL)

		return true unless validateStrings(sprO.StderrContent,'stderr',sprO.ServerSpec,'Exist',sprO.ServerURL)

		unless sprO.StdoutContent and sprO.StdoutContent.length > 0
			explanation = "No Stdout Content Saved from Probe"
			diagnostics = "sprO.StdoutContent.length not positive."
			@ErrorNote = ErrorNote.new(sprO.ServerSpec,sprO.ServerURL,explanation,diagnostics)
			return true
		end

		return true unless validateOverMinSize(sprO.StdoutContent,'stdout',sprO.ServerSpec,sprO.ServerURL)

		return true unless validateStrings(sprO.StdoutContent,'stdout',sprO.ServerSpec,'NoFail',sprO.ServerURL)

		return true unless validateStrings(sprO.StdoutContent,'stdout',sprO.ServerSpec,'Exist',sprO.ServerURL)

		return false
	end

	def validateOverMinSize(contentStr,contentType,serverStr,serverURL)
		validateStringObject(contentStr,'validateOverMinSize(contentStr,contentType,serverStr)')
		validateStringObject(contentType,'validateOverMinSize(contentStr,contentType,serverStr)')
		validateStringObject(serverStr,'validateOverMinSize(contentStr,contentType,serverStr)')
		return false unless contentStr
		@MinSize[contentType].keys.each do |sstr|
			next unless sstr == 'All' or serverStr =~ /#{sstr}/
			unless contentStr.length >= @MinSize[contentType][sstr]
				explanation = "FAIL validateOverMinSize[#{contentType}]:  " +
					"server[#{serverStr}](sstr:#{sstr}), " +
					"Minimum Size for #{contentType} is #{@MinSize[contentType][sstr]}, " +
					"actual is #{contentStr.length}."
				@ErrorNote = ErrorNote.new(serverStr,serverURL,explanation,diagnostics)
				return false
			end
		end
		return true
	end

	def validateStrings(contentStr,contentType,serverStr,passType,serverURL)
		validateStringObject(contentStr,'validateStrings(contentStr,contentType,serverStr,passType)')
		validateStringObject(contentType,'validateStrings(contentStr,contentType,serverStr,passType)')
		validateStringObject(serverStr,'validateStrings(contentStr,contentType,serverStr,passType)')
		validateStringObject(passType,'validateStrings(contentStr,contentType,serverStr,passType)')
		unless contentStr and contentStr.class == String and contentStr =~ /\S+/
			explanation = "FAIL NO CONTENT (#{contentStr}) for server."
			@ErrorNote = ErrorNote.new(serverStr,serverURL,explanation,"")
			return false
		end
		@Strings[passType][contentType].keys.each do |sstr|
			next unless sstr == 'All' or serverStr =~ /#{sstr}/
			@Strings[passType][contentType][sstr].each do |teststr|
				explanation = nil
				diagnostics = nil
				case passType
				when 'Exist'
					unless contentStr =~ /#{teststr}/
						explanation = "Required pattern '#{teststr}' was not found in #{contentType}."
						diagnostics = "FAIL validateAllExistStrings[#{contentType}]:  " +
							"server[#{serverStr}](sstr:#{sstr}), Required String[#{teststr}]."
					end
				when 'NoFail'
					if $Content[contentType] =~ /#{teststr}/
						explanation = "Failure pattern '#{teststr}' found in #{contentType}."
						diagnostics = "FAIL validateNoFailStrings[#{contentType}]:  " +
							"server[#{serverStr}](sstr:#{sstr}), Forbidden String[#{teststr}]."
					end
				else
					raise SyntaxError, "Invalid passType #{passType}."
				end
				if explanation then
					@ErrorNote = ErrorNote.new(serverStr,serverURL,explanation,diagnostics)
					return false
				end
			end
		end
		return true
	end

end

class WeeklyEmailList < L3Abstract_EmailList

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Weekly Reporting List'
		@MinLines = 0
		@MaxLines = 128
		super(cfgDir)
	end

end

# # # # End Internal Classes

class DirectoryBase

	DefaultBaseDir = "#{ENV['HOME']}/waudkit"

	protected

	def validateAbsSpec(dirStr)
		unless dirStr =~ /^\/\S\S+[^\/]$/
			raise ArgumentError,
				"Invalid #{self.class} directory argument |#{dirStr}|"
		end
	end

	def validateNodeSpec(nodeStr)
		unless nodeStr =~ /^[^\/]+\S*[^\/]+$/
			raise ArgumentError,
				"Invalid #{self.class} directory argument |#{nodeStr}|"
		end
	end

	public

	attr_reader :BaseDir, :CfgNode

	def initialize(cfgNode,baseDir=DefaultBaseDir)
		validateNodeSpec(cfgNode)
		validateAbsSpec(baseDir)

		@BaseDir		= baseDir
		@CfgNode		= cfgNode
		@CfgDir			= "#{@BaseDir}/#{@CfgNode}"
	end

end

#        01234567890123456789012345678901234567890123456789012345678901234567890

class ProbeBattery < DirectoryBase
	# Base cfg class for a single probe step.

	class ProbeAddress < DirectoryBase

		attr_accessor :AddrHash

		def initialize(cfgDir,addrType,addrHash)
			@CfgDir = cfgDir
			@AddrHash = Hash.new
			Dir["#{@CfgDir}/??"].each do |addrnospec|
				addrnostr = addrnospec.sub("#{@CfgDir}/",'')
				unless addrnostr =~ /^\d{2}$/
					raise ArgumentError, "Invalid Address No String format (should be ddd):  |#{addrnostr}|"
				end
				addrstr = File.read(addrnospec)
				case addrType
				when 'hostname'
					@AddrHash[addrnostr]	= WaudHostName.new(addrstr)
				when 'ipaddress'
					@AddrHash[addrnostr]	= WaudIPAddress.new(addrstr)
				when 'url'
					@AddrHash[addrnostr]	= WaudURL.new(addrstr)
				else
					raise ArgumentError, "Invalid address type extension '#{addrtype}'"
				end
			end
		end

		def each_addr(sortDescending=false)
			aha = @AddrHash.keys.sort       unless sortDescending
            aha = @AddrHash.keys.sort.reverse   if sortDescending
            aha.each do |ak|
                yield(@AddrHash[ak])
            end
		end

		def getAddr(addrnostr)
			return @AddrHash[addrnostr]
		end

	end

	attr_accessor :AddressList, :BinaryPOSTData, :CurlHTTPHeaders, :POSTData,
			:TestAppTimeout, :Validations

	def initialize(addrNode,baseDir)
		super(cfgNode,baseDir)

		@BinaryPOSTData		= BinaryPOSTData.new(@CfgDir)
		@CurlHTTPHeaders	= CurlHTTPHeaders.new(@CfgDir)
		@POSTData			= POSTData.new(@CfgDir)
		@TestAppTimeout		= TestAppTimeout.new(@CfgDir)
		@Validations		= Validations.new(@CfgDir)

		@AddressHash		= Hash.new # Because this yields a simple way to compare element name unqieness between ProbeSets
		# 3 character id required:  
		#				ddd
		Dir["#{@CfgDir}/step.?.*"].sort.each do |spec|
			addrnostr = spec.sub(/#{@CfgDir}\//,'')
			unless addrnostr =~ /^step\.(\d)\.(.*)$/
				raise ArgumentError, "Invalid Address No String format (should be step.probeno.addrtype):  |#{addrnostr}|"
			end
			probeno = $1
			addrtype = $2
			@StepHash[probeno] = ProbeAddress.new(spec,addrtype)
		end
	end

end # of Probe class

#        01234567890123456789012345678901234567890123456789012345678901234567890

class AdHocTest < DirectoryBase
	# Base cfg class for a test battery set.  This class includes all
	# 	needed for any arbitrary probe set, but does not include enough
	#	for ongoing monitoring.

	attr_accessor :AppTrace, :Cookies, :CurlHTTPHeaders, :ProbeSequence,
			:StowProbeTimestamps, :TimeoutOverAppMax

	def initialize(cfgNode,baseDir)
		super(cfgNode,baseDir)

		@AppTrace				= AppTrace.new(@CfgDir)
		@Cookies				= Cookies.new(@CfgDir)
		@CurlHTTPHeaders		= CurlHTTPHeaders.new(@CfgDir)
		@StowProbeTimestamps	= StowProbeTimestamps.new(@CfgDir)
		@TimeoutOverAppMax		= TimeoutOverAppMax.new(@CfgDir)

		@ProbeSequence			= Array.new(@CfgDir)

		# Loop of reading Probe configurations here
	end

end # of AdHocBattery class

#        01234567890123456789012345678901234567890123456789012345678901234567890

class Test < AdHocTest
	# Includes all the data needed for data collection in an ongoing
	# monitoring activity.

	attr_accessor :AdminEmailList, :CrontabPeriod, :FailureRange,
		:FailureRangeStartOffset, :IgnoreStdout, :MinSitings4Failure,
		:NotificationList, :ReNotificationPeriod, :ReNotificationStartMinute,
		:TestAppTimeout, :TestName

	def initialize(cfgNode,baseDir)
		super(cfgNode,baseDir)

		@AdminEmailList				= AdminEmailList.new(@CfgDir)
		@CrontabPeriod				= CrontabPeriod.new(@CfgDir)
		@FailureRange 				= FailureRange.new(@CfgDir)
		@FailureRangeStartOffset	= FailureRangeStartOffset.new(@CfgDir)
		@IgnoreStdout				= IgnoreStdout.new(@CfgDir)
		@MinSitings4Failure 		= MinSitings4Failure.new(@CfgDir)
		@NotificationList			= NotificationList.new(@CfgDir)
		@ReNotificationPeriod		= ReNotificationPeriod.new(@CfgDir)
		@ReNotificationStartMinute	= ReNotificationStartMinute.new(@CfgDir)
		@TestAppTimeout				= TestAppTimeout.new(@CfgDir)
		@TestName					= TestName.new(@CfgDir)
	end

end # of Battery class

#        01234567890123456789012345678901234567890123456789012345678901234567890

class AdminTest < Test
	# Includes all the data needed for reporting and probe configuration
	# maintenance.

	attr_accessor :BottomColumns, :BottomHelp, :BottomTests, :DailyEmailList,
		:MonthlyEmailList, :Label, :RefreshSeconds, :TopHelp, :TopTests,
		:WeeklyEmailList

	def initialize(cfgNode,baseDir)
		super(cfgNode,baseDir)

		@BottomColumns		= BottomColumns.new(@CfgDir)
		@BottomHelp			= BottomHelp.new(@CfgDir)
		@BottomTests		= BottomTests.new(@CfgDir)
		@DailyEmailList		= DailyEmailList.new(@CfgDir)
		@MonthlyEmailList	= MonthlyEmailList.new(@CfgDir)
		@Label				= Label.new(@CfgDir)
		@RefreshSeconds		= RefreshSeconds.new(@CfgDir)
		@TopHelp			= TopHelp.new(@CfgDir)
		@TopTests			= TopTests.new(@CfgDir)
		@WeeklyEmailList	= WeeklyEmailList.new(@CfgDir)
	end

end # of AdminBattery class

#        01234567890123456789012345678901234567890123456789012345678901234567890

class AdhocTestSet < DirectoryBase

	attr_accessor :AllProbesTimeout, :ProbeDefaultTimeout, :UserData

	def loadTests
		@DataCollectionTests.each_test do |tname|
			@TestList.push(AdhocBattery.new(tname,@CfgDir))
		end
	end

	def initialize(cfgNode,baseDir)
		super(cfgNode,baseDir)

		@AllProbesTimeout		= AllProbesTimeout.new(@CfgDir)
		@DataCollectionTests	= DataCollectionTests.new(@CfgDir)
		@ProbeDefaultTimeout	= ProbeDefaultTimeout.new(@CfgDir)
		@UserData				= UserData.new(@CfgDir)

		@TestList				= Array.new

		loadTests
	end

end # of AdhocTestSet

#        01234567890123456789012345678901234567890123456789012345678901234567890

class MonitorTestSet < AdhocTestSet

	# Cfg organized version of ProbeKit::TestList

	attr_accessor :AllDataExpirationMinutes, :TimeRangeDefinitions,
		:TrackedProblemExpiration

	def loadTests
		@DataCollectionTests.each_test do |tname|
			@TestList.push(Battery.new(tname,@CfgDir))
		end
	end

	def initialize(cfgNode,baseDir)

		@AllDataExpirationMinutes	= AllDataExpirationMinutes.new(@CfgDir)
		@TimeRangeDefinitions		= TimeRangeDefinitions.new(@CfgDir)
		@TrackedProblemExpiration	= TrackedProblemExpiration.new(@CfgDir)

		super(cfgNode,baseDir)

	end

end # of Tests class

class AdminTestSet < MonitorTestSet

	def loadTests
		@DataCollectionTests.each_test do |tname|
			@TestList.push(AdminBattery.new(tname,@CfgDir))
		end
	end

end

end # End of CfgSet module
