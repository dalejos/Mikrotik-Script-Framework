:local dhcpBound $bound;
:local dhcpServerAddress $"server-address";
:local dhcpLeaseAddress $"lease-address";
:local dhcpInterface $interface;
:local dhcpGatewayAddress $"gateway-address";
:local dhcpVendorSpecific $"vendor-specific";
:local dhcpLeaseOptions $"lease-options";
:local strDhcpLeaseOptions [:tostr $dhcpLeaseOptions];

/log info "bound: $dhcpBound";
/log info "server-address: $dhcpServerAddress";
/log info "lease-address: $dhcpLeaseAddress";
/log info "interface: $dhcpInterface";
/log info "gateway-address: $dhcpGatewayAddress";
/log info "vendor-specific: $dhcpVendorSpecific";
/log info "lease-options: $strDhcpLeaseOptions";

# DHCP CLIENT SCRIPT (VALID)
:local interfacename "ether1";
:local wan1newgw [ip dhcp-client get [find interface=$interfacename] gateway];
:local wan1routegw [/ip route get [find comment="WAN1"] gateway ];
:if ($wan1newgw != $wan1routegw) do={
     /ip route set [find comment="WAN1"] gateway="$wan1newgw%$interfacename";	 
	 /ip route set [find comment="WAN1MARK"] gateway="$wan1newgw%$interfacename";
}

# DHCP CLIENT SCRIPT (BEST)
:local dhcpGatewayAddress $"gateway-address";
:if ($bound = 1) do={
    /ip route set [find comment~"WAN1" gateway!="$dhcpGatewayAddress%$interface"] gateway="$dhcpGatewayAddress%$interface";
}



