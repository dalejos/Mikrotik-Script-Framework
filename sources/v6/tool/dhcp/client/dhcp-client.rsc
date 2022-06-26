:local dhcpBound $bound;
:local dhcpGatewayAddress $"gateway-address";
:local findComment "WAN1";

:if ($dhcpBound = 1) do={
	/ip route set [find comment~"$findComment" gateway!="$dhcpGatewayAddress"] gateway="$dhcpGatewayAddress";
}