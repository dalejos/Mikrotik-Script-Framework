#PIHOLE DOWN

:local dnsServer "172.16.2.1, 1.1.1.1";

/ip/dns/set servers=$dnsServer;

:set dnsServer "192.168.88.1";

:local networkAddress "192.168.88.0/24";
:local id [/ip/dhcp-server/network/find where address=$networkAddress];

/ip/dhcp-server/network/set $id dns-server=$dnsServer;

/log/info "PIHOLE DOWN.";