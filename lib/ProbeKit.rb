#2345678901234567890123456789012345678901234567890123456789012345678901234567890
module ProbeKit

# Excuse for doing this:
#
#	1.  When I was young, most adults had small earthenware or metal commodity
#	containers in the kitchen for things like flour, white sugar, and the keys
#	to the jeep.  Anyway, one thing I noticed in my family is that the stuff
#	often ran out unexpectedly because people never looked in the jars except
#	when they needed the contents.
#
#	2.  The actual shell level handle, like ping, curl, or wget, are the ones
#	that get the most use, and therefore get the best maintenance, and are more
#	quickly up-to-date with upgrades.
#
#	3.	If I run things through the shell command, at some point there will be
#	a full string shell command that gets generated.  For auditing, I can
#	provide a feature that actually pulls this out explicitly for use ad hoc
#	by an auditor or other hacker.
#
#23456789  23456789  23456789  23456789  23456789  23456789  23456789  234567890
#
# Classes provided in this module include:
#	ProbeKitBase >
#		ProbeTestList
#		TestBattery
#		ProbeSet
#		Probe >
#			MBD:CurlFTP
#			CurlHTTP
#			TBD:CurlIMAP
#			MBD:CurlLDAP
#			TBD:CurlPOP3
#			MBD:CurlSCP
#			TBD:CurlSMTP
#			MBD:CurlTELNET
#			PingICMP
#			TBD:SSHP2
#		
		
	require 'uri'

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
	
	class ProbeKitBase

		protected

		def generateDefaultNode
			raise ArgumentError,
		"generateDefaultNode is Pure Virtual in this parent class."
		end

		def getTimeOutNo(timeOut,minInt,maxInt)
			# Set timeout to be at least 1 second, but less than 30 minutes,
			# or maximally (30 * 60) - 1 = 1799 seconds).
			raise ArgumentError, "Bad range '#{minInt}'" unless minInt.kind_of?(Fixnum)
			raise ArgumentError, "Bad range '#{maxInt}'" unless minInt.kind_of?(Fixnum)
			lto = timeOut
			unless timeOut.kind_of?(Fixnum)
				utn = timeOut.strip
				unless utn =~ /^\d{1,4}$/ then
					clist = timeOut.ancestors if timeOut.respond_to?(:ancestors)
					clist = timeOut.class unless timeOut.respond_to?(:ancestors)
					raise ArgumentError, "Error non-number timeout |#{timeOut}| (#{clist})"
				end
				lto = utn.to_i
			end
			unless minInt <= lto and lto <= maxInt
				raise ArgumentError, "TimeOut '#{lto}' out of range {'#{minInt},#{maxInt}}."
			end
			return lto
		end

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

		attr_reader :BaseDir, :DataDir, :DataNode, :TimeOut

		def assureDir(probeDir=@DataDir)
			if File.exists?(probeDir)
				if File.directory?(probeDir)
					return
				else
					raise LoadError,
	"ERROR:  Directory Spec #{probeDir} exists as a non-directory item!"
				end
			end
			cmdstr="mkdir -p --mode=0777 #{probeDir}"
			`#{cmdstr}`
		end

		def clearDir(probeDir=@DataDir)
			raise ArgumentError unless probeDir =~ /\S{4,64}/
			`rm -rf #{probeDir}`
		end

		def initialize(dataNode='default')
			validateNodeSpec(dataNode)
			@DataNode		= dataNode
			setBaseDir('/tmp')
			@TimeOut		= 5
		end

		def readContent
			raise ArgumentError, "readContent is Pure Virtual in this parent class."
		end

		def readLog2
			raise ArgumentError, "readLog2 is Pure Virtual in this parent class."
		end

		def setBaseDir(bDir)
			validateAbsSpec(bDir)
			@BaseDir		= bDir
			@DataDir		= "#{@BaseDir}/#{@DataNode}"
		end

	end

	class Probe < ProbeKitBase

		# # Internals, should be protected, but working around a Minitest bug for now

		def parseAddress(addrO)
			raise ArgumentError, "new is Pure Virtual in this parent class."
		end

		def setFileSpecs
			@CmdTextSpec	= nil							if @TraceOff
			@CmdTextSpec	= "#{@DataDir}/cmdtext"		unless @TraceOff
			@StdoutSpec		= "#{@DataDir}/stdout"
			@StderrSpec		= "#{@DataDir}/stderr"
		end

		public

		attr_reader :Addr, :CmdTextSpec, :StderrSpec, :StdoutSpec, :TraceOff

		def execute
			pcmd = getCmd
			assureDir
			File.open(@CmdTextSpec,"w").write(pcmd)	unless @TraceOff
			bstampcmd = "echo \"Begin:  $(date +%s.%N)\" >#{@StderrSpec}"
			fullprobecmd = getCmd
			estampcmd = "echo \"End:  $(date +%s.%N)\" >>#{@StderrSpec}"
			`#{bstampcmd};#{fullprobecmd};#{estampcmd}` 
		end

		def getCmd
			raise ArgumentError, "getCmd is Pure Virtual in this parent class."
		end

		def initialize(dNode,addrO)
			super(dNode)
			@Addr			= parseAddress(addrO)
			setFileSpecs

			@TimeOut = 60
			@TraceOff		= false	# By default have all trace settings on
		end

		def readContent
			File.read(@StdoutSpec)
		end

		def readLog2
			File.read(@StderrSpec)
		end

		def setBaseDir(bDir)
			super(bDir)
			setFileSpecs
		end

		def setTimeOut(timeOut)
			begin
				@TimeOut = getTimeOutNo(timeOut,1,1799)
			rescue NoMethodError, NameError => buffer
				raise ArgumentError, "From NoMethodError:  #{buffer}"
			end
		end

		def traceOff
			@TraceOff		= true
			@CmdTextSpec	= nil
		end

	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class CurlFTP < Probe

		def parseAddress(addrO)
			raise ArgumentError, "Error nil address." if addrO.nil?
			raise ArgumentError, "Error blank address." if addrO.length == 0
			laddr = addrO					if addrO.kind_of?(URI)
			laddr = URI.parse(addrO)	unless addrO.kind_of?(URI)
			unless laddr.scheme == 'ftp' or laddr.scheme == 'tftp' or
				laddr.scheme == 'sftp' or laddr.scheme == 'ftps'
				raise ArgumentError, "Bad Scheme '#{laddr.scheme}'."
			end
			return laddr
		end

	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class CurlHTTP < Probe

		def parseAddress(addrO)
			raise ArgumentError, "Error nil address." if addrO.nil?
			raise ArgumentError, "Error blank address." if addrO.length == 0
			laddr = addrO					if addrO.kind_of?(URI)
			laddr = URI.parse(addrO)	unless addrO.kind_of?(URI)
			unless laddr.scheme == 'http' or laddr.scheme == 'https'
				raise ArgumentError, "Bad Scheme '#{laddr.scheme}'."
			end
			return laddr
		end

		def setFileSpecs
			super
			@CookieSpec		= "#{@DataDir}/cookies"
		end

		public


		attr_reader :CurlHTTPHeaders, :POSTFileSpec, :POSTFileType,
			:CookieSpec

		def self.address2servicename(mURL)
			if mURL.respond_to?(:host) and mURL.respond_to?(:port) then
				return "#{mURL.host}:#{mURL.port}"
			elsif mURL.respond_to?(:strip) then
				lurl = mURL.strip
				unless lurl =~ /^https?:\/\/\S\S+$/
					raise ArgumentError, "non-URL '#{lurl}'"
				end
				servicename = lurl.sub(/^https?:[\/]{2}/,'').sub(/\/.*/,'')
				return servicename
			else
				raise ArgumentError,"Invalid mURL argument '#{mURL}'."
			end
		end

		def generateDefaultNode
			hostport = CurlHTTP.address2servicename(@Addr)
			return hostport
		end

		def getCmd
			curlswitches = "-k -s -v -L -m #{@TimeOut}"
			curlswitches = "-b #{@CookieSpec} -c #{@CookieSpec} #{curlswitches}"
			curlswitches += " --trace-time" unless @TraceOff
			if not @CurlHTTPHeaders.nil? and
				@CurlHTTPHeaders.length > 0 and
				@CurlHTTPHeaders =~ /\S+/ then
				curlswitches += " #{@CurlHTTPHeaders}"
			end
			if @POSTFileType
				curlswitches += " --data-ascii @#{@POSTFileSpec}"	if @POSTFileType == :ascii
				curlswitches += " --data-binary @#{@POSTFileSpec}"	if @POSTFileType == :binary
			end

			pcmd = "curl #{curlswitches} '#{@Addr}'"
			return "#{pcmd} -o #{@StdoutSpec} 2>>#{@StderrSpec}"
		end

		def readCookies
			File.read(@CookieSpec)
		end

		def setPOST(postFileSpec,postType=:ascii)
			raise ArgumentError,"nil POST filespec."			if postFileSpec.nil?
			raise ArgumentError,"Zero length POST filespec."	if postFileSpec.length == 0
			raise ArgumentError,"No Such File"				unless File.exists?(postFileSpec)
			unless postType == :ascii or postType == :binary
				raise ArgumentError, "Invalid POST File Type '#{postType}'"
			end
			@POSTFileType = postType
			@POSTFileSpec = postFileSpec
		end

	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class CurlIMAP < Probe
	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class CurlLDAP < Probe
	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class CurlPOP3 < Probe
	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class CurlSCP < Probe
	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class CurlSMTP < Probe
	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class CurlTELNET < Probe
	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class PingICMP < Probe

		public

		def self.address2servicename(addrO)
			raise ArgumentError, "Error nil address." if addrO.nil?
			raise ArgumentError, "Error blank address." if addrO.length == 0
			unless addrO =~ /^[a-zA-Z_\.][a-zA-Z_\.0-9]+$/
				raise ArgumentError, "Error Invalid hostname:  #{addrO}."
			end
			return addrO
		end

		def generateDefaultNode
			return @Addr
		end

		def getCmd
			pingswitches = "-c 1 -W #{@TimeOut}"
			pingswitches += " -v" unless @TraceOff

			pcmd = "ping #{pingswitches} '#{@Addr}'"
			return "#{pcmd} >>#{@StdoutSpec} 2>>#{@StderrSpec}"
		end

		def parseAddress(addrO)
			raise ArgumentError, "Error nil address." if addrO.nil?
			raise ArgumentError, "Error blank address." if addrO.length == 0
			unless addrO =~ /^[a-zA-Z_\.][a-zA-Z_\.0-9]+$/
				raise ArgumentError, "Error Invalid hostname:  #{addrO}."
			end
			addrO
		end

	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class SSHP2 < Probe

	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class ProbeSequence < ProbeKitBase

		# Contains the list of all the probes, either a sequence, or a parallel
		# running set of cooperative services, for a given server activity to be
		# tested.

		public

		attr_reader :Sequence

		def addProbe(pO)
			if pO.kind_of?(Probe)
				pO.setBaseDir(@DataDir)
				@Sequence.push(pO)
			else
				clist = sO.ancestors if sO.respond_to?(:ancestors)
				clist = sO.class unless sO.respond_to?(:ancestors)
				raise ArgumentError,
					"Argument (#{clist}), not a ProbeCfg."
			end
		end

		def execute
			assureDir
			@Sequence.each do |po|
				po.execute
			end
		end 

		def generateDefaultNode
			return 'generic_test_id'
		end

		def initialize(dNode)
			@Sequence			= Array.new

			super(dNode)

			@TimeOut			= 66
		end

		def readContent(createHash=false)
			ca = Array.new		unless createHash
			ch = Hash.new			if createHash
			@Sequence.each do |po|
				content = po.readContent
				ca.push(content)		unless createHash
				ch[po.DataNode] = content	if createHash
			end
			return ca 	unless createHash
			return ch		if createHash
		end

		def readLog2(createHash=false)
			la = Array.new		unless createHash
			lh = Hash.new			if createHash
			@Sequence.each do |po|
				log2 = po.readLog2
				la.push(log2)		unless createHash
				lh[po.DataNode] = log2	if createHash
			end
			return la 	unless createHash
			return lh		if createHash
		end

		def setBaseDir(bDir)
			super(bDir)
			@Sequence.each do |bo|
				bo.setBaseDir(@DataDir)
			end
		end

		def setTimeOut(timeOut)
			begin
				@TimeOut = getTimeOutNo(timeOut,3,1800)
			rescue NoMethodError, NameError => buffer
				raise ArgumentError, "From NoMethodError:  #{buffer}"
			end
		end

	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class TestBattery < ProbeKitBase

		# Meant to hold a list of probes, usually for a given probe
		# Type or Configuration for running over many URLs/Servers.

		public

		attr_reader :Battery

		def addProbe(pO)
			unless pO.kind_of?(Probe) or pO.kind_of?(ProbeSequence)
				clist = pO.ancestors if pO.respond_to?(:ancestors)
				clist = pO.class unless pO.respond_to?(:ancestors)
				raise ArgumentError,
					"Bad object not in 'Probe' family:  |#{pO.ancestors}|."
			end
			if @Battery.has_key?(pO.DataNode) then
		raise ArgumentError, "Duplicate Data Node '#{pO.DataNode}'."
			end
			pO.setBaseDir(@DataDir)
			@Battery[pO.DataNode] = pO
		end

		def executeParallel
			assureDir
			@Battery.keys.each do |pok|
				# Assign a thread here
				@Battery[pok].execute
			end
			# Collect all this level's threads here, then proceed
		end

		def executeSerial
			assureDir
			@Battery.each_value do |po|
				po.execute
			end
		end

		def generateDefaultNode
			return 'generic_battery_id'
		end

		def initialize(dNode)
			@Battery = Hash.new

			super(dNode)

			setBaseDir('/tmp')
			@TimeOut = 75
		end

		def length
			return @Battery.keys.length
		end

		def readContent
			ch = Hash.new
			@Battery.keys.each do |bk|
				ch[bk] = @Battery[bk].readContent
			end
			return ch
		end

		def readLog2
			lh = Hash.new
			@Battery.keys.each do |bk|
				lh[bk] = @Battery[bk].readLog2
			end
			return lh
		end

		def setBaseDir(bDir)
			super(bDir)
			@Battery.values.each do |po|
				po.setBaseDir(@DataDir)
			end
		end

		def setTimeOut(timeOut)
			begin
				@TimeOut = getTimeOutNo(timeOut,4,1799)
			rescue NoMethodError, NameError => buffer
				raise ArgumentError, "From NoMethodError:  #{buffer}"
			end
		end

	end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

	class ProbeTestList < ProbeKitBase

		# Contains the list of all the probe sets (used to be called 'services')
		# that the instance of Spot is to be monitoring.

		def validateArrayOfTests(testHash)
			unless testHash.kind_of?(Hash)
				raise ArgumentError,
"Non-Array passed: '#{testHash}' (#{testHash.class})."
			end
			testHash.each do |lto|
				unless lto.kind_of?(TestBattery)
					clist = lto.ancestors if lto.respond_to?(:ancestors)
					clist = lto.class unless lto.respond_to?(:ancestors)
					raise ArgumentError,
					"Non-ProbeSetCfg family object passed (#{clist})."
				end
			end
		end

		public

		attr_reader :TestHash

		def addTest(tbO)
			unless tbO.kind_of?(TestBattery)
				clist = tbO.ancestors if tbO.respond_to?(:ancestors)
				clist = tbO.class unless tbO.respond_to?(:ancestors)
				raise ArgumentError,
	"Object not in 'TestBattery' family of classes: {#{clist}}."
			end
			if @TestHash.has_key?(tbO.DataNode) then
		raise ArgumentError, "Duplicate Data Node '#{tbO.DataNode}'."
			end
			tbO.setBaseDir(@DataDir)
			@TestHash[tbO.DataNode] = tbO
		end

		def executeParallel(serialBattery=false)
			assureDir
			@TestHash.keys.each do |tk|
				# Assign a thread here
				@TestHash[tk].executeParallel	unless serialBattery
				@TestHash[tk].executeSerial			if serialBattery
			end
			# Collect all this level's threads here, then proceed
		end

		def executeSerial(parallelBattery=false)
			assureDir
			@TestHash.keys.each do |tk|
				@TestHash[tk].executeSerial	unless parallelBattery
				@TestHash[tk].executeParallel	if parallelBattery
			end
		end

		def generateDefaultNode
			return 'generic_test_list_id'
		end

		def initialize(dNode)
			@TestHash	= Hash.new

			super(dNode)

			@TimeOut = 90
		end
		
		def length
			return @TestHash.keys.length
		end

		def readContent
			ch = Hash.new
			@TestHash.keys.each do |tk|
				ch[tk] = @TestHash[tk].readContent
			end
			return ch
		end

		def readLog2
			lh = Hash.new
			@TestHash.keys.each do |tk|
				lh[tk] = @TestHash[tk].readLog2
			end
			return lh
		end

		def setBaseDir(bDir)
			super(bDir)
			@TestHash.each do |lo|
				lo.setBaseDir(@DataDir)
			end
		end

		def setTimeOut(timeOut)
			begin
				@TimeOut = getTimeOutNo(timeOut,5,3600)
			rescue NoMethodError, NameError => buffer
				raise ArgumentError, "From NoMethodError:  #{buffer}"
			end
		end

	end

end # End of Module ProbeKit
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# end of ProbeKit.rb
