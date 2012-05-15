#!/bin/bash
#
#	rt.bash - execute test suites

if [[ -z $RUBYLIB ]]
then
	export RUBYLIB=$HOME/shop/snt
fi

if [[ -z $SpotTestOutputDir ]]
then
	export SpotTestOutputDir=/tmp/SpoTB
	mkdir -p $SpotTestOutputDir
fi
TopDir=$RUBYLIB/test/reports/$(date +%Y%m%d%H%M%S)


function printUsage()
{
	echo "./all.bash [-c] [-l]"
	echo " -c Clear out all old test output listings."
	echo " -l Local:  Run only tests not requiring Internet to pass."
}

function runTestSuite()
{
	tsuite=$1
	if [[ ! -e $tsuite.rb ]] 
	then
		echo "Fatal:  Test suite '$tsuite.rb' does not exist."
	fi
	checksum=$(cksum $tsuite.rb | awk '{print $1}')
	tdir=$TopDir/$tsuite.$checksum
	mkdir -p $SpotTestOutputDir
	mkdir -p $tdir
	ruby $tsuite.rb			>$tdir/stdout
	mv -f $SpotTestOutputDir/*	$tdir 2>/dev/null
}

for a in $*
do
	if [[ $a = '-c' ]]
	then
		rm -rf $RUBYLIB/test/reports
	elif [[ $a = '-l' ]]
	then
		InternetOnly=true
	else
		printUsage
		exit 1
	fi
done

runTestSuite 'ProbeKitTest.l'

if [[ -z $InternetOnly ]]
then
	runTestSuite 'ProbeKitTest.i'
fi
