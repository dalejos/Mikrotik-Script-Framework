:global zerotierNetwork;
:global zerotierNetworkListMembers;

{
	:local zn [$zerotierNetwork];

	:foreach n in=($zn->"data") do={
		:put ("Red: " . $n->"config"->"name");
		:put "******************************";
		:local zlm [$zerotierNetworkListMembers ($n->"id")];
		
		:foreach lm in=($zlm->"data") do={
			:put ($lm->"name" . ": " . $lm->"clock" . " - " . $lm->"lastSeen" . " - " . (($lm->"clock") - ($lm->"lastSeen")));
		}
		:put "";
	}
}