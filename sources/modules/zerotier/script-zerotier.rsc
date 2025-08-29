:global zerotierNetwork;
:global zerotierNetworkListMembers;

{
	:local zn [$zerotierNetwork];

	:foreach n in=($zn->"data") do={
		:put ("Red: " . $n->"config"->"name");
		:put "******************************";
		:local zlm [$zerotierNetworkListMembers ($n->"id")];
		
		:foreach lm in=($zlm->"data") do={
			:local lastSeen (($lm->"clock") - ($lm->"lastSeen"));
			:local m "segundo(s)";
			:set lastSeen ($lastSeen / 1000);
			
			:if ($lastSeen > 60) do={
				:set lastSeen ($lastSeen / 60);
				:set m "minuto(s)";
				
				:if ($lastSeen > 60) do={
					:set lastSeen ($lastSeen / 60);
					:set m "hora(s)";
					:if ($lastSeen > 24) do={
						:set lastSeen ($lastSeen / 24);
						:set m "dia(s)";
					}
				}
			}
			
			
			:put ($lm->"name" . " (" . ($lm->"config"->"ipAssignments"->0) . ")" . " visto hace $lastSeen $m.");
		}
		:put "";
	}
}