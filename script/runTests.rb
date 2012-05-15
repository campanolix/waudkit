#!/usr/bin/ruby
#
# runProbeSets.rb
#
# Script is divided in to the following:
#
#	i.		Initialize Object Sets.
#	ii.		Do Each Probe Set, and wait for them to finish to collect back
#			back the threads.
#	iii.	Release the buffered probe data to the report area.
#	iv.		Clean up buffers.
#	v.		Identify non-passing data by:
#			a)	Flagging it with a stamp file
#			b)	Saving it to a history
#	vi.		send notifications
#			a)	For new failures specified by general default, or probe
#			specific tests
#			b)	For ongoing failures
#	vii.	Make new emails more well formatted
#	viii.	Retire tracked new problems that now pass.
#	ix.		Stamp uptime points for Spot itself, and for probed sites.
#	x.		Handle outstanding exceptions

require "lib/FlatKit.rb"
include FlatKit
require "lib/ProbeKit.rb"
include ProbeKit

require 'timeout'

begin
	#	i.		Initialize Object Sets.
	#
	BaseDir = ENV['SPOT_BASEDIR']
	Mo		= Minute.new(BaseDir,Time.now)
	PSo	= ProbeSetList.new(Mo.BaseDir)

	# The next three constants will be thread safe:

	CDIR = Mo.CfgDir
	ODIR = Mo.OutDir
	TPBDIR = Mo.getTimePointBufferDir

	# The following may be best done as a class method:
	# `mkdir -p #{TPBDIR}`

	# main activities to process probe set list data

	#	ii.		Do Each Probe Set, and wait for them to finish to collect back
	#			back the threads.

	probe_threads = Array.new

	totalprobesets = 0
	puts "Begin probes:"
	PSo.each_probeset do |lpso|
		psid = lpso.ProbeSetId
		lpso.each_addressid do |laddressid|
			probe_threads << Thread.new(psid,TPBDIR,laddrid) do |tpsid,tdir,taddrid|
				tso = ProbeSet.new(tpsid,tdir,tso,CDIR,ODIR)
				tso.execute
			end
			totalprobesets += 1
		end
	end

	begin
		Timeout::timeout(OverallTimeout) do
			probe_threads.each { |t|  t.join }
			puts "All probe threads collected."
		end
	rescue Timeout::Error => eo
		puts "#{eo.message},"
		puts "Exiting before joining all probe threads"
		puts "Overall timeout set to #{OverallTimeout} seconds."
	end
	puts "End of #{totalprobes} probes executed."

	#	iii.	Release the buffered probe data to the report area.
	Mo.releaseProbeResults($NowObject)

	#	iv.		Clean up buffers.
	Mo.clearUnusedTimePoints($NowObject)
	Mo.clearOldBufferPoints($NowObject)

	#	v.		Identify non-passing data by:
	#			a)	Flagging it with a stamp file
	#			b)	Saving it to a history

	Mo.saveNonPassingProbes($NowObject)

	#	vi.		send notifications
	#			a)	For new failures specified by general default, or probe
	#			specific tests
	#			b)	For ongoing failures

	enoteo = Mo.collectImmediateNotifications($NowObject)
	Mo.sendImmediate(enoteo,$NowObject) if enoteo.notesExist?

	#	vii.	Make new emails more well formatted
	Mo.retireTrackedNewProblemsThatNowPass
	
	#	viii.	Retire tracked new problems that now pass.
	Mo.stampUptimePoint($NowObject)
	
	#	ix.		Stamp uptime points for Spot itself, and for probed sites.
rescue Exception => detail
	#	x.		Handle outstanding exceptions
	bt = detail.backtrace.join("\n")
	msg = "#{detail},\nbt:\n#{bt}"
	Mo.sendAdmin('Spot Probe Exception',msg)
end
#
# end of runProbeSets.rb
