# ProbeKitTest.l.rb
#
gem 'minitest'

require 'lib/ProbeKit'
require 'minitest/spec'
require 'minitest/autorun'

include ProbeKit

TestDir = "#{ENV['SpotTestOutputDir']}"

describe ProbeKit do

	it "should be a module" do
		ProbeKit.must_be_instance_of Module
	end

	describe "ProbeKitBase" do

		it "should be a class" do
			ProbeKitBase.must_be_instance_of Class
		end

		it "should instantiate to a ProbeKitBase object:" do
			ProbeKitBase.new('some/Node/string').must_be_instance_of ProbeKitBase
		end

		it "must be silent to instantiate:" do
			lambda { ProbeKitBase.new('nodestr') }.must_be_silent
		end

		it "ProbeKitBase objects must behave as follows with these evoked methods:" do
			pkbo = ProbeKitBase.new('nodestr')
			pkbo.DataNode.must_equal 'nodestr'
			pkbo.BaseDir.must_equal '/tmp'
			pkbo.DataDir.must_equal '/tmp/nodestr'
			pkbo.TimeOut.must_equal 1
			pkbo.setBaseDir('/home/xeno')
			pkbo.BaseDir.must_equal '/home/xeno'
			pkbo.DataNode.must_equal 'nodestr'
			pkbo.DataDir.must_equal '/home/xeno/nodestr'
		end

	end

	describe "CurlFTP" do
	end

	describe "CurlGOPHER" do
	end

	describe "CurlHTTP" do

		it "should instantiate to a CurlHTTP object:" do
			CurlHTTP.new('mynode','http://ssc.com').must_be_instance_of CurlHTTP
		end

		it "must be silent to instantiate:" do
			lambda { CurlHTTP.new('nodestr','http://some.place.around.here') }.must_be_silent
		end

		it "must fail on non-http scheme:" do
			lambda { CurlHTTP.new('nodestr','ftp://some.place.around.here') }.must_raise(ArgumentError)
			lambda { CurlHTTP.new('nodestr','scp://some.place.around.here') }.must_raise(ArgumentError)
			lambda { CurlHTTP.new('nodestr','smtp://some.place.around.here') }.must_raise(ArgumentError)
			lambda { CurlHTTP.new('nodestr','gopher://some.place.around.here') }.must_raise(ArgumentError)
			lambda { CurlHTTP.new('nodestr','imap://some.place.around.here') }.must_raise(ArgumentError)
		end

		it "must raise argument error if arguments left off:" do
			lambda { CurlHTTP.new("http://blek.com") }.must_raise(ArgumentError)
			lambda { CurlHTTP.new("fakeid") }.must_raise(ArgumentError)
			lambda { CurlHTTP.new }.must_raise(ArgumentError)
		end

		it "must raise argument error if an argument is bad:" do
			lambda { CurlHTTP.new(nil,'http://hostname') }.must_raise(ArgumentError)
			lambda { CurlHTTP.new("",'http://hostname') }.must_raise(ArgumentError)
			lambda { CurlHTTP.new("fakeid",'') }.must_raise(ArgumentError)
			lambda { CurlHTTP.new("fakeid",nil) }.must_raise(ArgumentError)
		end

		it "CurlHTTP.new must behave as follows with these evoked methods:" do
			cho = CurlHTTP.new('nodestr','http://www.aa.net')
			cho.DataNode.must_equal 'nodestr'
			cho.BaseDir.must_equal '/tmp'
			cho.DataDir.must_equal '/tmp/nodestr'
			cho.TimeOut.must_equal 1
			cho.setBaseDir('/home/campanolix')
			cho.BaseDir.must_equal '/home/campanolix'
			cho.DataNode.must_equal 'nodestr'
			cho.DataDir.must_equal '/home/campanolix/nodestr'
		end

		it "must show the following default values on this basic instantiation:" do
			url = 'http://www.google.com'
			cho = CurlHTTP.new('nodestr',url)

			cho.Addr.class.must_equal URI::HTTP
			"#{cho.Addr}".must_equal url
			cho.CmdTextSpec.must_equal	'/tmp/nodestr/cmdtext' 
			cho.DataNode.must_equal		'nodestr' 
			cho.StderrSpec.must_equal	'/tmp/nodestr/stderr' 
			cho.StdoutSpec.must_equal	'/tmp/nodestr/stdout' 
			cho.TimeOut.must_equal		1
			cho.TraceOff.must_equal		false

			cho.CurlHTTPHeaders.must_equal	nil
			cho.POSTFileSpec.must_equal		nil
			cho.POSTFileType.must_equal		nil
			cho.CookieSpec.must_equal		'/tmp/nodestr/cookies'
			cho.Addr.class.must_equal		URI::HTTP
			cho.Addr.scheme.must_equal		'http'
			cho.Addr.host.must_equal		'www.google.com'
		end

		it "must be able to modify BaseDir and have corresponding modifications:" do
			cho = CurlHTTP.new('nodestr','http://www.eskimo.com')
			cho.setBaseDir('/home/px')
			cho.DataNode.must_equal		'nodestr' 
			cho.CmdTextSpec.must_equal	'/home/px/nodestr/cmdtext' 
			cho.StderrSpec.must_equal	'/home/px/nodestr/stderr' 
			cho.StdoutSpec.must_equal	'/home/px/nodestr/stdout' 
		end

		it "must generate a simple cmd which is reasonable:" do
			url = 'http://www.yahoo.com'
			cho = CurlHTTP.new('nodestr',url)
			cmdstr = cho.getCmd
			cmdstr.must_match /curl.*#{url}.*#{cho.StdoutSpec}.*#{cho.StderrSpec}/
			cmdstr.must_match /trace.*time/
		end

		it "TraceOff setting must work properly:" do
			url = 'http://www.alabastertester.com'
			cho = CurlHTTP.new('nodestr',url)
			cho.traceOff
			cho.CmdTextSpec.must_be_nil
			cmdstr = cho.getCmd
			cmdstr.must_match /curl.*#{url}.*#{cho.StdoutSpec}.*#{cho.StderrSpec}/
			cmdstr.wont_match /trace.*time/
		end

		it "generateDefaultNode must work properly:" do
			hostport = 'www.rockyhorror.org:80'
			cho = CurlHTTP.new('nodestr',"http://#{hostport}")
			cho.generateDefaultNode.must_equal hostport
		end

		it "read* methods must work properly:" do
			cho = CurlHTTP.new('nodestr',"http://hotmail.com")
			fake_stderr_content = "stderr content"
			fake_stdout_content = "stdout content"
			cho.assureDir
			fdo = File.open(cho.StderrSpec,'w')
			fdo.write(fake_stderr_content)
			fdo.close
			cho.readLog2.must_equal fake_stderr_content
			fdo = File.open(cho.StdoutSpec,'w')
			fdo.write(fake_stdout_content)
			fdo.close
			cho.readContent.must_equal fake_stdout_content
			fake_cookie_content = "name=Xeno"
			fdo = File.open(cho.CookieSpec,'w')
			fdo.write(fake_cookie_content)
			fdo.close
			cho.readCookies.must_equal fake_cookie_content
			cho.clearDir
		end

		it "setPOST must work properly:" do
			pcontent = "name=Xeno&issue=antsy"
			fspec = '/tmp/testPOSTfile.lst'
			File.open(fspec,'w').write(pcontent)
			cho = CurlHTTP.new('nodestr',"http://www.linuxjournal.com")
			cho.setPOST(fspec)
			cho.POSTFileSpec.must_equal fspec
			cho.POSTFileType.must_equal :ascii
			cho.setPOST(fspec,:binary)
			cho.POSTFileSpec.must_equal fspec
			cho.POSTFileType.must_equal :binary
			lambda { cho.setPOST }.must_raise ArgumentError
			lambda { cho.setPOST("") }.must_raise ArgumentError
			lambda { cho.setPOST("/tmp/not_there") }.must_raise ArgumentError
			lambda { cho.setPOST(fspec,:doesntexist) }.must_raise ArgumentError
			cho.clearDir
		end

		it "object.setTimeOut should function correctly:" do
			cho = CurlHTTP.new('tid','http://testhost.com')
			lambda { cho.setTimeOut(1) }.must_be_silent
			cho.TimeOut.must_equal 1
			lambda { cho.setTimeOut(60) }.must_be_silent
			cho.TimeOut.must_equal 60
		end

		it "object.setTimeOut should allow the following examples:" do
			cho = CurlHTTP.new('tid','http://testhost.com')
			cho.setTimeOut("45")
			cho.setTimeOut("1005")
			cho.setTimeOut(15)
			cho.setTimeOut(85)
			cho.setTimeOut(1799)
		end

		it "object.setTimeOut should NOT allow the following examples:" do
			cho = CurlHTTP.new('tid','http://testhost.com')
			lambda { cho.setTimeOut("") }.must_raise(ArgumentError)
			lambda { cho.setTimeOut(nil) }.must_raise(ArgumentError)
			lambda { cho.setTimeOut("xxxii") }.must_raise(ArgumentError)
			lambda { cho.setTimeOut(:xxxii) }.must_raise(ArgumentError)
		end

		it "should have a working CurlHTTP.address2servicename method that should yield a hostname:port string:" do
			CurlHTTP.address2servicename("http://hostname:80").must_equal 'hostname:80'
		end

		it "should fail with an argument error when CurlHTTP.address2servicename is given a blank argument:" do
			lambda { CurlHTTP.address2servicename("") }.must_raise(ArgumentError)
		end

		it "should fail with an argument error when CurlHTTP.address2servicename is given a nil argument:" do
			lambda { CurlHTTP.address2servicename(nil) }.must_raise(ArgumentError)
		end

	end

	describe "CurlIMAP" do
	end

	describe "CurlLDAP" do
	end

	describe "CurlPOP3" do
	end

	describe "CurlRTMP" do
	end

	describe "CurlSCP" do
	end

	describe "CurlSMTP" do
	end

	describe "CurlTELNET" do
	end

	describe "CurlTFTP" do
	end

	describe "PingICMP" do

		it "should be a class" do
			PingICMP.must_be_instance_of Class
		end

		it "should instantiate to a PingICMP object:" do
			PingICMP.new('mynode','ssc.com').must_be_instance_of PingICMP
		end

		it "must be silent to instantiate:" do
			lambda { PingICMP.new('nodestr','some.place.around.here') }.must_be_silent
		end

		it "must raise argument error if arguments left off:" do
			lambda { PingICMP.new("blek.com") }.must_raise(ArgumentError)
			lambda { PingICMP.new("fakeid") }.must_raise(ArgumentError)
			lambda { PingICMP.new }.must_raise(ArgumentError)
		end

		it "must raise argument error if an argument is bad:" do
			lambda { PingICMP.new(nil,'hostname') }.must_raise(ArgumentError)
			lambda { PingICMP.new("",'hostname') }.must_raise(ArgumentError)
			lambda { PingICMP.new("fakeid",'') }.must_raise(ArgumentError)
			lambda { PingICMP.new("fakeid",nil) }.must_raise(ArgumentError)
			lambda { PingICMP.new("fakeid",'http://google.com') }.must_raise(ArgumentError)
			lambda { PingICMP.new("fakeid",'ftp://www.download.net') }.must_raise(ArgumentError)
		end

		it "PingICMP.new must behave as follows with these evoked methods:" do
			cho = PingICMP.new('nodestr','www.aa.net')
			cho.DataNode.must_equal 'nodestr'
			cho.BaseDir.must_equal '/tmp'
			cho.DataDir.must_equal '/tmp/nodestr'
			cho.TimeOut.must_equal 1
			cho.setBaseDir('/home/xcampanoli')
			cho.BaseDir.must_equal '/home/xcampanoli'
			cho.DataNode.must_equal 'nodestr'
			cho.DataDir.must_equal '/home/xcampanoli/nodestr'
		end

		it "must show the following default values on this basic instantiation:" do
			hostname = 'www.google.com'
			cho = PingICMP.new('nodestr',hostname)

			cho.Addr.class.must_equal String
			cho.Addr.must_equal hostname
			cho.CmdTextSpec.must_equal	'/tmp/nodestr/cmdtext' 
			cho.DataNode.must_equal		'nodestr' 
			cho.StderrSpec.must_equal	'/tmp/nodestr/stderr' 
			cho.StdoutSpec.must_equal	'/tmp/nodestr/stdout' 
			cho.TimeOut.must_equal		1
			cho.TraceOff.must_equal		false
		end

		it "must be able to modify BaseDir and have corresponding modifications:" do
			cho = PingICMP.new('nodestr','www.eskimo.com')
			cho.setBaseDir('/home/px')
			cho.DataNode.must_equal		'nodestr' 
			cho.CmdTextSpec.must_equal	'/home/px/nodestr/cmdtext' 
			cho.StderrSpec.must_equal	'/home/px/nodestr/stderr' 
			cho.StdoutSpec.must_equal	'/home/px/nodestr/stdout' 
		end

		it "must generate a simple cmd which is reasonable:" do
			hostname = 'www.yahoo.com'
			cho = PingICMP.new('nodestr',hostname)
			cmdstr = cho.getCmd
			cmdstr.must_match /ping.*#{hostname}.*#{cho.StdoutSpec}.*#{cho.StderrSpec}/
			cmdstr.must_match /-v/
		end

		it "TraceOff setting must work properly:" do
			hostname = 'www.alabastertester.com'
			cho = PingICMP.new('nodestr',hostname)
			cho.traceOff
			cho.CmdTextSpec.must_be_nil
			cmdstr = cho.getCmd
			cmdstr.must_match /ping.*#{hostname}.*#{cho.StdoutSpec}.*#{cho.StderrSpec}/
			cmdstr.wont_match /-v/
		end

		it "generateDefaultNode must work properly:" do
			hostname = 'www.rockyhorror.org'
			cho = PingICMP.new('nodestr',hostname)
			cho.generateDefaultNode.must_equal hostname
		end

		it "read* methods must work properly:" do
			cho = PingICMP.new('nodestr',"hotmail.com")
			fake_stderr_content = "stderr content"
			fake_stdout_content = "stdout content"
			cho.assureDir
			fdo = File.open(cho.StderrSpec,'w')
			fdo.write(fake_stderr_content)
			fdo.close
			cho.readLog2.must_equal fake_stderr_content
			fdo = File.open(cho.StdoutSpec,'w')
			fdo.write(fake_stdout_content)
			fdo.close
			cho.readContent.must_equal fake_stdout_content
			cho.clearDir
		end

		it "object.setTimeOut should be silent:" do
			lambda { PingICMP.new('tid','testhost.com').setTimeOut(1) }.must_be_silent
		end

		it "object.setTimeOut should allow the following examples:" do
			cho = PingICMP.new('tid','testhost.com')
			cho.setTimeOut("45")
			cho.setTimeOut("1005")
			cho.setTimeOut(15)
			cho.setTimeOut(85)
			cho.setTimeOut(1799)
		end

		it "object.setTimeOut should NOT allow the following examples:" do
			cho = PingICMP.new('tid','testhost.com')
			lambda { cho.setTimeOut("") }.must_raise(ArgumentError)
			lambda { cho.setTimeOut(nil) }.must_raise(ArgumentError)
			lambda { cho.setTimeOut("xxxii") }.must_raise(ArgumentError)
			lambda { cho.setTimeOut(:xxxii) }.must_raise(ArgumentError)
		end

		it "should have a working PingICMP.address2servicename method that should just relay the hostname:" do
			PingICMP.address2servicename("hostname").must_equal 'hostname'
		end

		it "should fail with an argument error when PingICMP.address2servicename is given a hostname with a port number:" do
			lambda { PingICMP.address2servicename("hostname:80") }.must_raise(ArgumentError)
		end

		it "should fail with an argument error when PingICMP.address2servicename is given a blank argument:" do
			lambda { PingICMP.address2servicename("") }.must_raise(ArgumentError)
		end

		it "should fail with an argument error when PingICMP.address2servicename is given a nil argument:" do
			lambda { PingICMP.address2servicename(nil) }.must_raise(ArgumentError)
		end

	end

	describe "SSH" do
	end

	describe "ProbeSequence" do

		it "must have a new method that is silent:" do
			lambda { ProbeSequence.new('batteryId') }.must_be_silent
		end

		it "must raise argument error if id/node argument left off:" do
			lambda { ProbeSequence.new }.must_raise(ArgumentError)
		end

		it "must raise argument error if argument bad:" do
			lambda { ProbeSequence.new("") }.must_raise(ArgumentError)
		end

		it "must instantiate to an object with the following defaults:" do
			pso = ProbeSequence.new('someid')
			pso.BaseDir.must_equal '/tmp'
			pso.DataDir.must_equal '/tmp/someid'
			pso.Sequence.length.must_equal 0

			pso.setBaseDir('/home/espy')
			pso.DataNode.must_equal 'someid'
			pso.DataDir.must_equal '/home/espy/someid'

			pso.TimeOut.must_equal 1
			pso.DataDir.must_equal '/home/espy/someid'
		end

		it "must set its directory to be the upper directory to an added probe:" do
			pso = ProbeSequence.new('psid')
			pso.DataDir.must_equal '/tmp/psid'
			cho = CurlHTTP.new('chid',"http://chohostname.net")
			pso.addProbe(cho)
			cho.DataDir.must_equal '/tmp/psid/chid'
		end

		it "object.setTimeOut should be silent:" do
			lambda { ProbeSequence.new('tid').setTimeOut(3) }.must_be_silent
		end

		it "object.setTimeOut should allow the following examples:" do
			pso = ProbeSequence.new('tid')
			pso.setTimeOut("45")
			pso.setTimeOut("1005")
			pso.setTimeOut(15)
			pso.setTimeOut(85)
			pso.setTimeOut(1799)
		end

		it "object.setTimeOut should NOT allow the following examples:" do
			pso = ProbeSequence.new('tid')
			lambda { pso.setTimeOut(0) }.must_raise(ArgumentError)
			lambda { pso.setTimeOut("") }.must_raise(ArgumentError)
			lambda { pso.setTimeOut(nil) }.must_raise(ArgumentError)
			lambda { pso.setTimeOut("xxxii") }.must_raise(ArgumentError)
			lambda { pso.setTimeOut(:xxxii) }.must_raise(ArgumentError)
		end

		it "must have a working addProbe method:" do
			pso = ProbeSequence.new('bid')
			pso.Sequence.length.must_equal 0
			cho1 = CurlHTTP.new('zzpid',"http://zz.net")
			pso.addProbe(cho1)
			pso.Sequence.length.must_equal 1
			cho2 = CurlHTTP.new('yypid',"http://yy.net")
			pso.addProbe(cho2)
			pso.Sequence.length.must_equal 2
			cho3 = CurlHTTP.new('xxpid',"http://xx.net")
			pso.addProbe(cho3)
			pso.Sequence.length.must_equal 3
			cho4 = CurlHTTP.new('google','http://www.google.com')
			cho5 = CurlHTTP.new('twitter','http://www.twitter.com')
			cho6 = CurlHTTP.new('rhapsody','http://www.rhapsody.com')
			cho7 = CurlHTTP.new('int','http://www-int.rhapsody.com')
			cho8 = CurlHTTP.new('beta2','http://www-beta2.rhapsody.com')
			cho9 = CurlHTTP.new('rhaptools','http://rhaptools-prod-1201.sea2.rhapsody.com/~campanolix')
			choa = CurlHTTP.new('prod-1209-port80','http://rhapcom-prod-1209.sea2.rhapsody.com:80')
			chob = CurlHTTP.new('rotw-1209_port8180','http://rhapweb-prod-1209.sea2.rhapsody.com:8180/rotw/')
			choc = CurlHTTP.new('yahoo','http://www.yahoo.com')
			chod = CurlHTTP.new('hotmail','http://www.hotmail.com')
			choe = CurlHTTP.new('github','http://www.github.com')
			chof = CurlHTTP.new('eskimo','http://www.eskimo.com')
			chog = CurlHTTP.new('me','http://www.eskimo.com/~xeno')
			choh = CurlHTTP.new('Canonical','https://launchpad.net')
			pso.addProbe(cho4)
			pso.addProbe(cho5)
			pso.addProbe(cho6)
			pso.addProbe(cho7)
			pso.addProbe(cho8)
			pso.addProbe(cho9)
			pso.addProbe(choa)
			pso.addProbe(chob)
			pso.addProbe(choc)
			pso.addProbe(chod)
			pso.addProbe(choe)
			pso.addProbe(chof)
			pso.addProbe(chog)
			pso.addProbe(choh)
			pso.Sequence.length.must_equal 17
		end

		it "must be able to modify BaseDir and have corresponding modifications:" do
			cho = ProbeSequence.new('bid')
			cho.setBaseDir('/home/battery')
			cho.BaseDir.must_equal		'/home/battery' 
			cho.DataNode.must_equal		'bid' 
			cho.DataDir.must_equal		'/home/battery/bid' 
		end

	end

	describe "TestBattery" do

		it "must have a new method that is silent:" do
			lambda { TestBattery.new('some/test_node') }.must_be_silent
		end

		it "must have a new method that instantiates an instance of 'TestBattery':" do
			pto = TestBattery.new('FakeId')
			pto.must_be_instance_of TestBattery
			pto.must_be_kind_of ProbeKitBase
		end

		it "must raise argument error if id/node argument left off:" do
			lambda { TestBattery.new }.must_raise(ArgumentError)
		end

		it "must raise argument error if argument bad:" do
			lambda { TestBattery.new("") }.must_raise(ArgumentError)
		end

		it "must instantiate to an object with the following defaults:" do
			pto = TestBattery.new('anid')
			pto.BaseDir.must_equal '/tmp'
			pto.DataDir.must_equal '/tmp/anid'
			pto.Battery.keys.length.must_equal 0
			pto.length.must_equal 0
			pto.Battery.keys.length.must_equal pto.length

			pto.setBaseDir('/home/mozart')
			pto.DataNode.must_equal 'anid'
			pto.DataDir.must_equal '/home/mozart/anid'

			pto.TimeOut.must_equal 1
		end

		it "must set its directory to be the upper directory to added objects (independent of order):" do
			tbo = TestBattery.new('tbid')
			tbo.DataDir.must_equal '/tmp/tbid'
			pso = ProbeSequence.new('psid')
			pso.DataDir.must_equal '/tmp/psid'
			cho = CurlHTTP.new('chid',"http://chohostname.net")
			cho.DataDir.must_equal '/tmp/chid'

			tbo.addProbe(pso)
			pso.DataDir.must_equal '/tmp/tbid/psid'
			pso.addProbe(cho)
			cho.DataDir.must_equal '/tmp/tbid/psid/chid'

			tbo = TestBattery.new('tbid')
			tbo.DataDir.must_equal '/tmp/tbid'
			pso = ProbeSequence.new('psid')
			pso.DataDir.must_equal '/tmp/psid'
			cho = CurlHTTP.new('chid',"http://chohostname.net")
			cho.DataDir.must_equal '/tmp/chid'

			pso.addProbe(cho)
			cho.DataDir.must_equal '/tmp/psid/chid'

			tbo.addProbe(pso)
			pso.DataDir.must_equal '/tmp/tbid/psid'
			cho.DataDir.must_equal '/tmp/tbid/psid/chid'
		end

		it "object.setTimeOut should be silent:" do
			lambda { TestBattery.new('tid').setTimeOut(4) }.must_be_silent
		end

		it "object.setTimeOut should allow the following examples:" do
			pto = TestBattery.new('tid')
			pto.setTimeOut("45")
			pto.setTimeOut("1005")
			pto.setTimeOut(15)
			pto.setTimeOut(85)
			pto.setTimeOut(1799)
		end

		it "object.setTimeOut should NOT allow the following examples:" do
			pto = TestBattery.new('tid')
			lambda { pto.setTimeOut(0) }.must_raise(ArgumentError)
			lambda { pto.setTimeOut("") }.must_raise(ArgumentError)
			lambda { pto.setTimeOut(nil) }.must_raise(ArgumentError)
			lambda { pto.setTimeOut("xxxii") }.must_raise(ArgumentError)
			lambda { pto.setTimeOut(:xxxii) }.must_raise(ArgumentError)
		end

		it "object.TestBattery should show the correct number of steps added:" do
			tbo = TestBattery.new('FakeId')
			tbo.Battery.keys.length.must_equal 0
			tbo.length.must_equal 0
			ps1o = ProbeSequence.new('PSId1')
			ps1o.addProbe( CurlHTTP.new('PId1','http://www.one.net') )
			ps1o.addProbe( CurlHTTP.new('PId2','http://www.two.net') )
			tbo.addProbe( ps1o )
			tbo.length.must_equal 1
			tbo.Battery.length.must_equal 1
			ps2o = ProbeSequence.new('PSId2')
			ps2o.addProbe( CurlHTTP.new('PId3','http://www.three.net') )
			tbo.addProbe( ps2o )
			ps3o = ProbeSequence.new('PSId3')
			tbo.addProbe( ps3o )
			po4 = CurlHTTP.new('PId4','http://www.four.net')
			tbo.addProbe( po4 )
			po5 = PingICMP.new('PId5','www.five.net')
			tbo.addProbe( po5 )
			tbo.Battery.keys.length.must_equal tbo.length
			po6 = PingICMP.new('PId6','www.six.net')
			tbo.addProbe( po6 )
			tbo.Battery.keys.length.must_equal 6
			tbo.length.must_equal 6
		end

		it "object.executeSet should execute successfully offline when the list of batteries is empty:" do
			pto = TestBattery.new('FakeId')
			pto.length.must_equal 0
			lambda { pto.executeSerial }.must_be_silent
			lambda { pto.executeParallel }.must_be_silent
		end

	end

	describe "ProbeTestList" do

		it "must have a new method that is silent:" do
			lambda { ProbeTestList.new('testlist_id') }.must_be_silent
		end

		it "must raise argument error if id/node argument left off:" do
			lambda { ProbeTestList.new }.must_raise(ArgumentError)
		end

		it "must raise argument error if argument bad:" do
			lambda { ProbeTestList.new("") }.must_raise(ArgumentError)
		end

		it "must instantiate to an object with the following defaults:" do
			ptlo = ProbeTestList.new('thisid')
			ptlo.BaseDir.must_equal '/tmp'
			ptlo.DataDir.must_equal '/tmp/thisid'
			ptlo.length.must_equal 0
			ptlo.TestHash.keys.length.must_equal 0
			ptlo.TestHash.keys.length.must_equal ptlo.length

			ptlo.setBaseDir('/home/butterscotch')
			ptlo.DataNode.must_equal 'thisid'
			ptlo.DataDir.must_equal '/home/butterscotch/thisid'

			ptlo.TimeOut.must_equal 1
		end

		it "object.setTimeOut should be silent:" do
			lambda { ProbeTestList.new('tid').setTimeOut(5) }.must_be_silent
		end

		it "object.setTimeOut should allow the following examples:" do
			ptlo = ProbeTestList.new('tid')
			ptlo.setTimeOut("45")
			ptlo.setTimeOut("1005")
			ptlo.setTimeOut(15)
			ptlo.setTimeOut(85)
			ptlo.setTimeOut(1799)
		end

		it "object.setTimeOut should NOT allow the following examples:" do
			ptlo = ProbeTestList.new('tid')
			lambda { ptlo.setTimeOut(0) }.must_raise(ArgumentError)
			lambda { ptlo.setTimeOut("") }.must_raise(ArgumentError)
			lambda { ptlo.setTimeOut(nil) }.must_raise(ArgumentError)
			lambda { ptlo.setTimeOut("xxxii") }.must_raise(ArgumentError)
			lambda { ptlo.setTimeOut(:xxxii) }.must_raise(ArgumentError)
		end

		it "should be able to add tests successfully:" do
			ptlo = ProbeTestList.new('tid')
			ptlo.length.must_equal 0
			to1 = TestBattery.new('Tid1')
			pso1 = ProbeSequence.new('psid1')
			pso1.addProbe( CurlHTTP.new('PId1','http://www.one.net/menu') )
			pso1.addProbe( CurlHTTP.new('PId2','http://www.one.net/selection') )
			to1.addProbe(pso1)
			pso2 = ProbeSequence.new('psid2')
			pso2.addProbe( CurlHTTP.new('PId3','http://www.three.net') )
			to1.addProbe(pso2)
			ptlo.addTest(to1)
			ptlo.length.must_equal 1
			to2 = TestBattery.new('FakeId2')
			ptlo.addTest(to2)
			to3 = TestBattery.new('AnotherFakeId3')
			ptlo.addTest(to3)
			ptlo.length.must_equal 3
			ptlo.TestHash.keys.length.must_equal 3
		end

		it "object.executeParallel should execute successfully offline when the list of probes is empty:" do
			lambda { ProbeTestList.new('tid').executeParallel }.must_be_silent
		end

		it "object.executeSerial should execute successfully offline when the list of probes is empty:" do
			lambda { ProbeTestList.new('tid').executeSerial }.must_be_silent
		end

	end

end

# End of ProbeKitTest.l.rb
