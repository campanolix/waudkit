
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
	
# # # # Begin Internal Classes
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
#	Configuration Classes for loading, validating, and conveying flat file data.
#	The first few are base classes.
#

class SpotFlatCfg

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

class SpotSingleLineTextCfg < SpotFlatCfg

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

class SpotBooleanCfg < SpotSingleLineTextCfg

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

class SpotSpecOnlyCfg < SpotFlatCfg

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

class SpotWholeNoCfg < SpotSingleLineTextCfg

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

class SpotFlatListCfg < SpotFlatCfg

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

class SpotEmailList < SpotFlatListCfg

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

class ServiceList < SpotFlatListCfg

	protected

	def validateLine(lStr)
		SpotService.validateServiceId(lStr,'ServiceList validateLine(lStr)')
		dspec = "#{@ServicesCfgDir}/#{lStr}"
		unless File.exists?(dspec)
			raise ArgumentError,
	"Directory '#{dspec}' for Service List Id #{lStr} in #{@Label} not found."
		end
	end

	public

	def initialize(cfgDir)
		@CfgDir = validateAndStripAbsSpec(cfgDir,'ServiceList instantiator')
		@CfgName = self.class.to_s.sub(/^\S+::/,'')
		@CfgSpec = "#{@CfgDir}/#{@CfgName}"
		@ServicesCfgDir = "#{@CfgDir}/services"
		# This object can never be empty, so @EmptyOkay must always be false.
		@EmptyOkay = false
		parseAndValidate
	end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
#	Concrete Configuration Classes.
#

class BinaryPOSTData < SpotSpecOnlyCfg

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

class BottomColumns < SpotWholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Bottom Service Report Columns'
		@Minimum = 1
		@Maximum = 9
		super(cfgDir)
	end

end

class BottomHelp < SpotFlatListCfg

	public

	def initialize(cfgDir)
		@Label = 'Bottom Help Rows'
		@MinLines = 1
		@MaxLines = 4196
		super(cfgDir)
	end

end

class BottomRows < ServiceList

	public

	def initialize(cfgDir)
		@Label = 'Bottom Service Report Rows'
		@MinLines = 0
		@MaxLines = 32
		super(cfgDir)
	end

end

class ChainProbeList < SpotFlatListCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'List of Probes in Chain'
		@MinLines = 1
		@MaxLines = 4196
		super(cfgDir)
	end

end

class ChainProbeSequence < SpotWholeNoCfg

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'Sequence Number for Chain Probe'
		@Minimum = 0
		@Maximum = 9
		super(cfgDir)
	end

end

class Color < SpotSingleLineTextCfg
	
	protected

	def assignValueIfValid
		unless @LoadString =~ /^[a-z]{3,24}$/ or @Value =~ /^#\d{1,8}$/
			raise SyntaxError, "Bad Color Id #{@LoadString}."
		end
		@Value = @LoadString
	end

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Service Color'
		super(cfgDir)
	end

end

class Cookies < SpotBooleanCfg

	def initialize(cfgDir)
		@Label = 'Cookies Collected and Referenced (boolean)'
		super(cfgDir)
	end

end

class CronProbePeriod < SpotWholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Submission Period Specified in Crontab'
		@Minimum = 1
		@Maximum = 59
		super(cfgDir)
	end

end

class CurlHTTPHeaders < SpotSingleLineTextCfg

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

class CurlTimeout < SpotWholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Service Curl Timeout'
		@Minimum = 1
		@Maximum = 300
		super(cfgDir)
	end

end

class DailyEmailList < SpotEmailList

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Daily Reporting List'
		@MinLines = 0
		@MaxLines = 128
		super(cfgDir)
	end

end

class FailureRange < SpotWholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Failure Range'
		@Minimum = 5
		@Maximum = 30
		super(cfgDir)
	end

end

class FailureRangeStartOffset < SpotWholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Offset To Failure Range'
		@Minimum = 0
		@Maximum = 29
		super(cfgDir)
	end

end

class IgnoreStdout < SpotBooleanCfg

	def initialize(cfgDir)
		@Label = 'Ignore Stdout Data from Probe'
		super(cfgDir)
	end

end

class Label < SpotSingleLineTextCfg
	
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

class MinSitings4Failure < SpotWholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Service Specific Minimum Sitings for Failure'
		@Minimum = 1
		@Maximum = 8
		super(cfgDir)
	end

end

class MonthlyEmailList < SpotEmailList

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Monthly Reporting List'
		@MinLines = 0
		@MaxLines = 128
		super(cfgDir)
	end

end

class NotificationList < SpotEmailList

	public

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'Failure Notification List'
		@MinLines = 0
		@MaxLines = 128
		super(cfgDir)
	end

end

class NotificationMinutes < SpotWholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'Notification Minutes'
		@Minimum = 0
		@Maximum = 60
		super(cfgDir)
	end

end

class POSTData < SpotSpecOnlyCfg

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

class ProbeSequenceStartMinute < SpotWholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'Probe Start Minute in Hour'
		@Minimum = 0
		@Maximum = 59
		super(cfgDir)
	end

end

class RecentSitingMinutes < SpotWholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Recent Siting Minutes'
		@Minimum = MinMinuteHistoryRange
		@Maximum = MaxMinuteHistoryRange
		super(cfgDir)
	end

end

class RefreshSeconds < SpotWholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Refresh Seconds'
		@Minimum = 15
		@Maximum = 300
		super(cfgDir)
	end

end

class ServersDefaultMinutes < SpotWholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Servers Default Minutes'
		@Minimum = MinMinuteHistoryRange
		@Maximum = MaxMinuteHistoryRange
		super(cfgDir)
	end

end

class AdminEmailList < SpotEmailList

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Spot Administration Email List'
		@MinLines = 1
		@MaxLines = 16
		super(cfgDir)
	end

end

class StowProbeTimestamps < SpotBooleanCfg

	public

	def initialize(cfgDir)
		@Label = 'Collect and Stow Times for Steps in Probes.'
		super(cfgDir)
	end

end

class TimeoutOverCurlMax < SpotWholeNoCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Timeout Over Curl Max'
		@Minimum = 5
		@Maximum = 300
		super(cfgDir)
	end

end

class TopHelp < SpotFlatListCfg

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'NavBar Function Help'
		@MinLines = 1
		@MaxLines = 4196
		super(cfgDir)
	end

end

class TopRows < ServiceList

	public

	def initialize(cfgDir)
		@EmptyOkay = true
		@Label = 'Top Service Report Rows'
		@MinLines = 0
		@MaxLines = 9
		super(cfgDir)
	end

end

class TraceURLs < SpotBooleanCfg

	public

	def initialize(cfgDir)
		@Label = 'Turn on Traces of URLs probed.'
		super(cfgDir)
	end

end

class TrackedProblemExpiration < SpotWholeNoCfg

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

class URLList < SpotFlatListCfg

	protected

	def validateLine(lStr)
		validateAndStripURL(lStr,"instantiator for #{@Label}")
	end

	public

	def initialize(cfgDir)
		@EmptyOkay = false
		@Label = 'Service URL List'
		@MinLines = 1
		@MaxLines = 100
		super(cfgDir)
	end

	def dumpAsHTML
		markup = ""
		@Value.each do |line|
			markup += "<nobr>" + CGI.escapeHTML(line) + "</nobr><br />\n"
		end
		return markup
	end

	def getURLByServerSpec(sSpec)
		@Value.each do |lurl|
			lsurl = validateAndStripURL(lurl,"instantiator for #{@Label}")
			sspec = Regexp.escape(sSpec)
			return lsurl if lsurl =~ /#{sspec}/
		end
		return nil
	end

	def hasURL?(urlStr)
		@Value.each do |lurl|
			return true if lurl == urlStr
		end
		return false
	end

end

class Validations < SpotFlatCfg

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
		ServerProbeRecord.validateObject(sprO,'hasServerFailure?(sprO)')

		unless sprO.StderrContent.length > 0 
			explanation = "No Stderr Diagnostics Saved from Probe"
			diagnostics = "sprO.StderrContent.length not positive."
			@ErrorNote = ErrorNote.new(sprO.ServerSpec,sprO.ServerURL,explanation,diagnostics))
			return true
		end

		unless sprO.StderrContent =~ /#{SuccessHTTPRegex}/
			explanation = "No 200 OK HTTP header found."
			diagnostics = "Primary Failure Type:  Missing HTTP 200 OK!\n" +
				"FAIL on Content2(#{sprO.ServerSpec}, " +
				"length #{sprO.StderrContent.length})) " +
				"match with SuccessHTTPRegex:  #{SuccessHTTPRegex}."
			@ErrorNote = ErrorNote.new(sprO.ServerSpec,sprO.ServerURL,explanation,diagnostics))
			return true
		end
		
		return true unless validateOverMinSize(sprO.StderrContent,'stderr',sprO.ServerSpec,sprO.ServerURL)

		return true unless validateStrings(sprO.StderrContent,'stderr',sprO.ServerSpec,'NoFail',sprO.ServerURL)

		return true unless validateStrings(sprO.StderrContent,'stderr',sprO.ServerSpec,'Exist',sprO.ServerURL)

		unless sprO.StdoutContent and sprO.StdoutContent.length > 0
			explanation = "No Stdout Content Saved from Probe"
			diagnostics = "sprO.StdoutContent.length not positive."
			@ErrorNote = ErrorNote.new(sprO.ServerSpec,sprO.ServerURL,explanation,diagnostics))
			return true
		end

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
				@ErrorNote = ErrorNote.new(serverStr,serverURL,explanation,diagnostics))
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
			@ErrorNote = ErrorNote.new(serverStr,serverURL,explanation,""))
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
					@ErrorNote = ErrorNote.new(serverStr,serverURL,explanation,diagnostics))
					return false
				end
			end
		end
		return true
	end

end

class WeeklyEmailList < SpotEmailList

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
