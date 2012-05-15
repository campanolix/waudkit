#2345678901234567890123456789012345678901234567890123456789012345678901234567890
module ProbeKit

	require 'lib/FlatTools.rb'
	require 'lib/Validations.rb'

	require 'lib/Configurations.rb'

	include FlatTools
	include Validations
	include Configurations

#23456789  23456789  23456789  23456789  23456789  23456789  23456789  234567890
		
#        01234567890123456789012345678901234567890123456789012345678901234567890

	def url2servername(mURL)
		lurl =
			validateAndStripURL(mURL,'ServerProbeRecord.url2servername(mURL)')
		servername = lurl.chomp.sub(/http[s]*:[\/]{2}/,'').sub(/\/.*/,'')
		return servername
	end

#        01234567890123456789012345678901234567890123456789012345678901234567890
	# Elemental Interface Methods
	
	public

#        01234567890123456789012345678901234567890123456789012345678901234567890
	# Higher Level Object Interface Methods

	class CurlProbeCfg

		attr_accessor :CronProbePeriod, :CurlHTTPHeaders, :CurlTimeout,
			:Label, :POSTData, :StowProbeTimestamps, :TraceURLs, :URLList

		def initialize(pLabel,cTimeout)
			@CurlTimeout	= cTimeout
			@Label			= pLabel
			@IgnoreStdout	= false
		end

		def ignoreStdout
			@IgnoreStdout = true
		end

		def setPOSTDataSpec(postType=nil,postDataSpec)
			@POSTFileType = postType
			@POSTDataSpec = postDataSpec
		end

	end

	class CurlProbe < CurlProbeCfg

		def initialize(urlStr,timeOut,httpHeaders,timeStamps=false)
			@URL		= ulrStr
			@Timout		= timeOut
			@HTTPHdrs	= httpHeaders
			@TimeStamps	= timeStamps
		end

		def getProbeCmd(cookieSpec,postDataSpec,pDT=nil)
			curlswitches = "-k -s -v -L -m #{@CurlTimeout.Value}"
			curlswitches = "-b #{cookieSpec} -c #{cookieSpec} #{curlswitches}" if @Cookies.Value
			curlswitches += " --trace-time" if @StowProbeTimestamps.Value
			if @CurlHTTPHeaders.Value.length > 0 and
				@CurlHTTPHeaders.Value =~ /\S+/ then
				curlswitches += " #{@CurlHTTPHeaders.Value}"
			end
			if postDataType then
				curlswitches += " --data-ascii @#{postDataSpec}" if pDT == 'ascii'
				curlswitches += " --data-binary @#{postDataSpec}" if pDT == 'binary'
			end

			return "curl #{curlswitches} '#{lurl}'"
		end

	end

	class Probe

		CookieFile = "spotcookies.lst"
		
		def initialize(pDir,pNo,pCmd)
			@PDir = pDir
			@PNo = pNo
			@PCmd = pCmd
		end

		def executeProbe
			cookiespec = "#{@PDir}/#{CookieFile}"
			fspec1 = "#{@PDir}/#{@StdoutFile}.#{@PNo}"
			fspec2 = "#{@PDir}/#{@StderrFile}.#{@PNo}"
			bstampcmd = "echo \"Begin:  $(date +%s.%N)\" >#{fspec2}"
			fullprobecmd = "#{@PCmd} -o #{fspec1} 2>>#{fspec2}"
			estampcmd = "echo \"End:  $(date +%s.%N)\" >>#{fspec2}"
			`#{bstampcmd};#{fullprobecmd};#{estampcmd}`
			return fspec1,fspec2
		end

	end
	
	class ProbeSeqCfg
		def initialize(
	end

	class ProbeSequence

		
	end

end # End of Module Probe
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# end of Probe.rb
