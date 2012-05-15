module Minutes

	require 'lib/FlatTools.rb'
	require 'lib/Validations.rb'

	require 'lib/Configurations.rb'
	require 'lib/Probe.rb'

	include FlatTools
	include Validations
	include Configurations
	include Probe

	@@FieldName					= Hash.new
	@@FieldName['AckList']		= 'acklist'
	@@FieldName['Comments']		= 'comments'
	@@FieldName['Cookies']		= 'cookies'
	@@FieldName['Diagnostics']	= 'diagnostics'
	@@FieldName['Explanation']	= 'explanation'
	@@FieldName['Stderr']		= Channel2
	@@FieldName['Stdout']		= Channel1

	def hasAcknowledgement?(pDir)	{ hasFlatFileFieldData?('AckList',pDir,true) }
	def hasAnyCookieData?(pDir)		{ hasFlatFileFieldData?('Cookies',pDir,true) }
	def hasDiagnostics?(pDir)		{ hasFlatFileFieldData?('Diagnostics',pDir,true) }

	def hasError?(pDir=nil)
		return true if hasDiagnosticNote?(pDir)
		return true if hasExplanation?(pDir)
		return false
	end

	def hasExplanation?(pDir)		{ hasFlatFileFieldData?('Explanation',pDir,true) }

	def hasProbeData?(pDir)
		return true if hasStderr?(pDir) and hasStdout?(pDir)
		return false
	end

	def hasStderr?(pDir)			{ hasFlatFileFieldData?('Stderr',pDir,true) }
	def hasStdout?(pDir)			{ hasFlatFileFieldData?('Stdout',pDir,true) }

	def refreshFromFlatFiles(pDir)
		@@FieldName.keys.each do |fieldname|
			loadFlatFileFieldData(fieldname,pDir,@NonBlankRequired[fieldname])
		end
	end

	def saveAtFlatPoint(pDir)
		@@FieldName.keys.each do |fieldname|
			saveFlatFileFieldData?(fieldname,pDir)
		end
	end

	def appendAckList(pDir,userName,ticketStr)
		validatePointDirectory(pDir)
		validateStringObject(userName,'userName in appendAckList')
		validateStringObject(ticketStr,'ticketStr in appendAckList')
		fspec = "#{pDir}/#{@@FieldName['AckList']}"
		begin
			ostr = "#{userName}|#{Time.now}|#{ticketStr}\n"
			FlatTools.appendFile(fspec,ostr)
		rescue Exception
			note = "Problem trying to save file #{fspec}:  #{$!}"
			raise IOError, note
		end
	end

	def getAckList
		al = Array.new
		@Content['AckList'].each_line do |line|
			u,ts,tn = line.chomp.split("|")
			al.push([u,ts,tn])
		end
		return al
	end

	def getDirForPoint(pDir,ssO)
		pdir = validateAndStripAbsSpec(pDir,'getDirForPoint(pDir)')
		# This yields a server dir for any base point, as opposed to
		# ServerProbeDir, which is for specifically this object's
		# timepoint.
		sdir = ssO.getDirForPoint(pdir)
		return "#{sdir}/#{@ServerSpec}"
	end

	def hasFlatFileFieldData?(fffdName,pDir,nonBlankRequired=true)
		validatePointDirectory(pDir)
		validateFieldName(fffdName)
		spdir = getDirForPoint(pDir)
		fspec = validateAndStripAbsSpec("#{pdir}/#{fffdName}",
				'hasFlatFileFieldData?(fffdName,pDir,nonBlankRequired=true)')
		return false unless File.exists?(fspec)
		content = File.read(fspec)
		return false if content.length == 0 and nonBlankRequired
		return true
	end

	def loadFlatFileFieldData(fffdName,pDir,nonBlankRequired=true)
		validatePointDirectory(pDir)
		validateFieldName(fffdName)
		spdir = getDirForPoint(pDir)
		fspec = validateAndStripAbsSpec("#{pdir}/#{fffdName}",
				'loadFlatFileFieldData?(fffdName,pDir,nonBlankRequired=true)')
		unless File.exists?(fspec) 
			if nonBlankRequired then
				raise LoadError, "Required file #{fspec} does not exist."
			else
				return ""
			end
		end
		@Content[fffdName] = File.read(fspec)
	end

	def saveFlatFileFieldData?(fffdName,pDir,dataStr)
		validatePointDirectory(pDir)
		validateFieldName(fffdName)
		spdir = getDirForPoint(pDir)
		unless File.directory?(pDir)
			raise IOError, "Point Directory #{pDir} was not a valid directory." 
		end
		fspec = validateAndStripAbsSpec("#{pdir}/#{fffdName}",
				'saveFlatFileFieldData?(fffdName,pDir,dataStr)')
		File.open(fspec,"w").write(@Content[fffdName])
	end

	def validatePointDirectory(pDir)
		raise ArgumentError, "Point Directory must be non-blank." unless pDir
		unless File.directory?(pDir)
			raise ArgumentError,
			"Point Directory Argument '#{pDir}' is not a valid directory."
		end
	end

	def validateFieldName(fffdName)
		raise ArgumentError, "Field Name must be non-blank." unless fffdName
		unless @@FieldName.has_key?(fffdName)
			raise ArgumentError,
			"Invalid Field Name '#{fffdName}' for SpotProbeRecord field set."
		end
	end

	class Minute

		def fromErrorNote(ssO,eNote)
			lspro = ServerProbeRecord.new(ssO,eNOte.URL)
			@ErrorNote = eNote
			lspro.Diagnostics = eNote.Diagnostics
			lspro.Explanation = eNote.Explanation
			return lspro
		end

		def loadFlat(ssO,sURI,sDir)
			lspro = ServerProbeRecord.new(ssO,sURI)
			lspro.refreshFromFlatFiles(sDir)
			@ErrorNote =
				ErrorNote.new(@ServerSpec,@ServerURL,@Content['Explanation'],
								@Content['Diagnostics'])
			return lspro
		end

	end

	class MinuteVector
	end

	class MinuteMatrix
	end

end
