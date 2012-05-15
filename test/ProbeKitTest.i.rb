# ProbeKitTest.i.rb
#
gem 'minitest'

require 'lib/ProbeKit'
require 'minitest/spec'
require 'minitest/autorun'

include ProbeKit

TestDir = "#{ENV['SpotTestOutputDir']}"

describe ProbeKit do

	describe "CurlHTTP" do

		it "it should yield reasonable output:" do
			cho = CurlHTTP.new('CurlHTTP_test1','http://www.google.com')
			cho.clearDir
			lambda { cho.execute }.must_be_silent
			content = cho.readContent
			content.must_match /<html/
			content.must_match /<title>Google.*<\/title>/
			log2 = cho.readLog2
			log2.must_match /< HTTP\/1.1 200 OK/
			log2.must_match /> GET \/ HTTP/
			cookies = cho.readLog2
			cookies.must_match /.google.com/
			cho.clearDir
		end

	end


	describe "PingICMP" do

		it "it should yield reasonable output:" do
			pio = PingICMP.new('PingICMP_test1','www.google.com')
			pio.clearDir
			lambda { pio.execute }.must_be_silent
			content = pio.readContent
			content.must_match /PING/
			content.must_match /\(\d+.\d+.\d+.\d+\)/
			log2 = pio.readLog2
			log2.must_match /Begin:.*\d+.\d+/
			log2.must_match /End:.*\d+.\d+/
			pio.clearDir
		end

	end

	describe "ProbeSequence" do

		it "must be able to send multiple probes:" do
			pso = ProbeSequence.new('psid')
			cho1 = CurlHTTP.new('step1_google','http://google.com')
			pso.addProbe(cho1)
			cho2 = CurlHTTP.new('step2_eskimo','http://www.eskimo.com')
			pso.addProbe(cho2)
			cho3 = CurlHTTP.new('step3_rhapsody','http://rhapsody.com')
			pso.addProbe(cho3)
			cho4 = CurlHTTP.new('step4_hotmail','http://hotmail.com')
			pso.addProbe(cho4)
			cho5 = CurlHTTP.new('step5_twitter','http://twitter.com')
			pso.addProbe(cho5)
			pso.Sequence.length.must_equal 5
			pso.clearDir
			lambda { pso.execute }.must_be_silent

			cho1.DataDir.must_equal '/tmp/psid/step1_google'
			cho1.StdoutSpec.must_match /\/tmp\/psid\/step1_google/
			cho1.StderrSpec.must_match /\/tmp\/psid\/step1_google/
			cho1.readContent.must_match /<html/
			cho1.readCookies.must_match /\.google\.com/
			cho1.readLog2.must_match /< HTTP\/1.1 200 OK/
			cho2.DataDir.must_equal '/tmp/psid/step2_eskimo'
			cho2.readContent.must_match /<html/
			cho2.readLog2.must_match /< HTTP\/1.1 200 OK/
			cho3.DataDir.must_equal '/tmp/psid/step3_rhapsody'
			cho3.readContent.must_match /<html/
			cho3.readLog2.must_match /< HTTP\/1.1 200 OK/
			cho4.DataDir.must_equal '/tmp/psid/step4_hotmail'
			cho4.readContent.must_match /<html/
			cho4.readLog2.must_match /< HTTP\/1.1 200 OK/
			cho5.DataDir.must_equal '/tmp/psid/step5_twitter'
			cho5.StdoutSpec.must_match /\/tmp\/psid\/step5_twitter/
			cho5.StderrSpec.must_match /\/tmp\/psid\/step5_twitter/
			cho5.readContent.must_match /<html/
			cho5.readLog2.must_match /< HTTP\/1.1 200 OK/

			ca = pso.readContent
			la = pso.readLog2
			ca.length.must_equal la.length

			ca.each do |content|
				content.must_match /<html/
				content.must_match /html>/
			end
			la.each do |log2|
				log2.must_match /< HTTP\/1.1 200 OK/
				log2.must_match /> GET \/ HTTP/
			end

			ch = pso.readContent(true)
			lh = pso.readLog2(true)
			cka = ch.keys.sort
			lka = lh.keys.sort
			cka.must_equal lka
			cka.length.must_equal ca.length

			ch.keys.each do |pk|
				ch[pk].must_match /<html/
				lh[pk].must_match /< HTTP\/1.1 200 OK/
			end

			pso.clearDir
		end

		it "must be able to send a probe sequence with sequence dependencies:" do
		# timeout 1 second with first expected to fail
		end

		it "must be able to send a probe sequence with cookie dependencies:" do
		# Login / Log out.
		end

		it "must be able to send a probe sequence with cookie dependencies:" do
		# Int Account Set up
		end

		it "must be able to send a probe sequence with cookie dependencies:" do
		# $0.00 price MP3 Purchase
		end

		it "must be able to send a heterogeneous probe sequence with sequence dependencies:" do
		# Ping Int servers to reassure they are up.
		# Hit Pixies Int.
		# Extract Log Entries
		end

	end

	describe "TestBattery" do

		it "should be able to successfully run the test battery with a simple list:" do
			tbo = TestBattery.new('test1')
			tbo.clearDir
			tbo.length.must_equal 0
			tbo.addProbe( CurlHTTP.new('pid1','http://www.google.com') )
			tbo.addProbe( CurlHTTP.new('pid2','http://www.twitter.com') )
			tbo.addProbe( CurlHTTP.new('pid3','http://www.eskimo.com') )
			tbo.length.must_equal 3
			lambda { tbo.executeSerial }.must_be_silent
			tbo.Battery.each_key do |bk|
				tbo.Battery[bk].DataDir.must_match /^\/tmp\/test1\/#{bk}$/
				tbo.Battery[bk].CookieSpec.must_match /^#{tbo.Battery[bk].DataDir}\/cookies$/
				tbo.Battery[bk].StdoutSpec.must_match /^#{tbo.Battery[bk].DataDir}\/stdout$/
				tbo.Battery[bk].StderrSpec.must_match /^#{tbo.Battery[bk].DataDir}\/stderr$/
				tbo.Battery[bk].readContent.must_match /<html/
				tbo.Battery[bk].readLog2.must_match /< HTTP\/1.1 200 OK/
			end

			ch = tbo.readContent
			ch.class.must_equal Hash
			ch.keys.each do |bk|
				ch[bk].must_match /<html/
				ch[bk].must_match /html>/
			end
			lh = tbo.readLog2
			lh.class.must_equal Hash
			lh.keys.each do |bk|
				lh[bk].must_match /< HTTP\/1.1 200 OK/
				lh[bk].must_match /> GET \/ HTTP/
			end

			tbo.clearDir
		end

		it "should be able to successfully run the test battery with a complex list:" do
			tbo = TestBattery.new('test2')
			tbo.clearDir
			tbo.length.must_equal 0
			ps1o = ProbeSequence.new('PSId1')
			ps1o.addProbe( CurlHTTP.new('PId1','http://www.google.com') )
			ps1o.addProbe( CurlHTTP.new('PId2','http://www.twitter.com') )
			ps1o.addProbe( CurlHTTP.new('PId3','http://www.eskimo.com') )
			tbo.addProbe( ps1o )
			tbo.length.must_equal 1
			tbo.Battery.length.must_equal 1
			ps2o = ProbeSequence.new('PSId2')
			ps2o.addProbe( CurlHTTP.new('PId3','http://www.washington.edu') )
			tbo.addProbe( ps2o )
			ps3o = ProbeSequence.new('PSId3')
			tbo.addProbe( ps3o )
			po4 = CurlHTTP.new('PId4','http://www.yahoo.com')
			tbo.addProbe( po4 )
			po5 = PingICMP.new('PId5','www.rhapsody.com')
			tbo.addProbe( po5 )
			tbo.Battery.keys.length.must_equal tbo.length
			po6 = PingICMP.new('PId6','ssc.com')
			tbo.addProbe( po6 )
			tbo.Battery.keys.length.must_equal 6
			tbo.length.must_equal 6
			lambda { tbo.executeParallel }.must_be_silent
			tbo.Battery.each_key do |bk|
				tbo.Battery[bk].DataDir.must_match /^\/tmp\/test2\/#{bk}$/
				if tbo.Battery[bk].class == CurlHTTP then
					tbo.Battery[bk].StderrSpec.must_match /^#{tbo.Battery[bk].DataDir}\/stderr$/
					tbo.Battery[bk].StdoutSpec.must_match /^#{tbo.Battery[bk].DataDir}\/stdout$/
					tbo.Battery[bk].CookieSpec.must_match /^#{tbo.Battery[bk].DataDir}\/cookies$/
					tbo.Battery[bk].readContent.must_match /<html/
					tbo.Battery[bk].readLog2.must_match /< HTTP\/1.1 200 OK/
					log2 = tbo.Battery[bk].readLog2
					log2.must_match /Begin:.*\d+.\d+/
					log2.must_match /End:.*\d+.\d+/
				elsif tbo.Battery[bk].class == PingICMP then
					tbo.Battery[bk].StderrSpec.must_match /^#{tbo.Battery[bk].DataDir}\/stderr$/
					tbo.Battery[bk].StdoutSpec.must_match /^#{tbo.Battery[bk].DataDir}\/stdout$/
					content = tbo.Battery[bk].readContent
					content.must_match /PING/
					content.must_match /\(\d+.\d+.\d+.\d+\)/
					log2 = tbo.Battery[bk].readLog2
					log2.must_match /Begin:.*\d+.\d+/
					log2.must_match /End:.*\d+.\d+/
				elsif tbo.Battery[bk].class == ProbeSequence then
					tbo.Battery[bk].Sequence.each do |po|
						po.DataDir.must_match /^\/tmp\/test2\/#{bk}\/#{po.DataNode}$/
						po.StderrSpec.must_match /^#{po.DataDir}\/stderr$/
						po.StdoutSpec.must_match /^#{po.DataDir}\/stdout$/
						log2 = po.readLog2
						log2.must_match /Begin:.*\d+.\d+/
						log2.must_match /End:.*\d+.\d+/
						if po.class == CurlHTTP then
							po.CookieSpec.must_match /^#{po.DataDir}\/cookies$/
							po.readContent.must_match /<html/
							po.readLog2.must_match /< HTTP\/1.1 200 OK/
						elsif po.class == PingICMP then
							content = po.readContent
							content.must_match /PING/
							content.must_match /\(\d+.\d+.\d+.\d+\)/
						end
					end
				end
			end
			tbo.clearDir
		end

	end

	describe "ProbeTestList" do

		it "should be able to execute a simple list of tests:" do
			ptlo = ProbeTestList.new('test1')
			ptlo.clearDir
			ptlo.length.must_equal 0
			tbo = TestBattery.new('tbid1')
			tbo.addProbe( CurlHTTP.new('pid1','http://www.google.com') )
			tbo.addProbe( CurlHTTP.new('pid2','http://www.twitter.com') )
			tbo.length.must_equal 2
			ptlo.addTest(tbo)
			ptlo.length.must_equal 1
			tbo = TestBattery.new('tbid2')
			tbo.addProbe( CurlHTTP.new('pid3','http://www.eskimo.com') )
			tbo.length.must_equal 1
			ptlo.addTest(tbo)
			ptlo.length.must_equal 2
			lambda { ptlo.executeSerial }.must_be_silent
			ptlo.TestHash.each_key do |tlk|
				ptlo.TestHash[tlk].DataDir.must_match /^\/tmp\/test1\/#{tlk}$/
				tbo = ptlo.TestHash[tlk]
				tbo.Battery.each_key do |bk|
					tbo.Battery[bk].DataDir.must_match /^\/tmp\/test1\/#{tlk}\/#{bk}$/
					tbo.Battery[bk].CookieSpec.must_match /#{tbo.Battery[bk].DataDir}\/cookies$/
					tbo.Battery[bk].StdoutSpec.must_match /#{tbo.Battery[bk].DataDir}\/stdout$/
					tbo.Battery[bk].StderrSpec.must_match /#{tbo.Battery[bk].DataDir}\/stderr$/
					tbo.Battery[bk].readContent.must_match /<html/
					tbo.Battery[bk].readLog2.must_match /< HTTP\/1.1 200 OK/
				end
			end

			ch = ptlo.readContent
			ch.class.must_equal Hash
			ch.each_key do |tlk|
				ch[tlk].each_key do |bk|
					ch[tlk][bk].must_match /<html/
					ch[tlk][bk].must_match /html>/
				end
			end
			lh = ptlo.readLog2
			lh.class.must_equal Hash
			lh.keys.each do |tlk|
				lh[tlk].each_key do |bk|
					lh[tlk][bk].must_match /< HTTP\/1.1 200 OK/
					lh[tlk][bk].must_match /> GET \/ HTTP/
				end
			end

			ptlo.clearDir
		end

		it "should be able to execute a complex list of tests:" do
			ptlo = ProbeTestList.new('test2')
			ptlo.clearDir
			ptlo.length.must_equal 0
			to1 = TestBattery.new('tbid1')
			pso1 = ProbeSequence.new('psid1')
			pso1.addProbe( CurlHTTP.new('PId1','http://www.washington.edu') )
			pso1.addProbe( CurlHTTP.new('PId2','http://launchpad.net') )
			to1.addProbe(pso1)
			pso2 = ProbeSequence.new('psid2')
			pso2.addProbe( CurlHTTP.new('PId3','http://hotmail.com') )
			pso2.addProbe( CurlHTTP.new('PId4','http://yahoo.com') )
			pso2.addProbe( CurlHTTP.new('PId5','http://gmail.com') )
			to1.addProbe(pso2)
			ptlo.addTest(to1)
			ptlo.length.must_equal 1
			to2 = TestBattery.new('tbid2')
			to2.addProbe( CurlHTTP.new('PId6','http://www.eskimo.com') )
			to2.addProbe( CurlHTTP.new('PId7','http://igoogle.com') )
			to2.addProbe( CurlHTTP.new('PId8','http://rhap.com') )
			to2.addProbe( CurlHTTP.new('PId9','http://mp3.rhapsody.com') )
			ptlo.addTest(to2)
			to3 = TestBattery.new('tbid3')
			to3.addProbe( CurlHTTP.new('PId10','http://origin.rhapsody.com') )
			ptlo.addTest(to3)
			ptlo.length.must_equal 3
			lambda { ptlo.executeParallel }.must_be_silent
			
			ch = ptlo.readContent
			ch.class.must_equal Hash
			ch.each_key do |tlk|
				ch[tlk].each_key do |bk|
					if ch[tlk][bk].class == Array then
						ch[tlk][bk].each do |content|
							content.must_match /<html/
							content.must_match /html>/
						end
					else
						ch[tlk][bk].must_match /<html/
						ch[tlk][bk].must_match /html>/
					end
				end
			end
			lh = ptlo.readLog2
			lh.class.must_equal Hash
			lh.keys.each do |tlk|
				lh[tlk].each_key do |bk|
					if lh[tlk][bk].class == Array then
						lh[tlk][bk].each do |log2|
							log2.must_match /< HTTP\/1.1 200 OK/
							log2.must_match /> GET \/ HTTP/
						end
					else
						lh[tlk][bk].must_match /< HTTP\/1.1 200 OK/
						lh[tlk][bk].must_match /> GET \/ HTTP/
					end
				end
			end

			ptlo.clearDir
		end

	end

end

# End of ProbeKitTest.i.rb
