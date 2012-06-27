
module CfgKit

	class CfgAdministration
		# Configuration general access GUI and other mechanisms and lifecycle aspects
	end

	class CfgProbeSets < CfgAdministration
	end

	class CfgReporting < CfgProbeSets
	end

	class CfgHistoryExtraction < CfgReporting
	end

end

# Dimensions/aspects:
#	0.		QA Ad Hoc Version of Configurations, and perhaps more than one
#	1.		Primary Data Collection Script
#	2.		Primary Reporting / Tracking Load
#	3.		Configurations Management
#	4.		History Table of Configurations
