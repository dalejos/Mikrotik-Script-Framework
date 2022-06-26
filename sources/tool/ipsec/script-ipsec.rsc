:global ipsec;

:if (($ipsec->"count") < ($ipsec->"totalCount")) do={
	:local count ($ipsec->"count");
	:set ($ipsec->"rx"->$count) [interface get 0 rx-byte];
	:set ($ipsec->"tx"->$count) [interface get 0 tx-byte];
    :set ($ipsec->"count") ($count + 1);
} else={
    :set ($ipsec->"count") 0;
	
	:local isZero true;
	:foreach v in=($ipsec->"rx") do={
		:set isZero ($isZero && ($v = 0));
		:put $v;
	}
	:put $isZero;
}
