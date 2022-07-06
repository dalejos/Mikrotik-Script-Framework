#PIHOLE UP

:local dnsServer "10.11.12.2";

/ip/dns/set servers=$dnsServer;

:local networkAddress "192.168.88.0/24";
:local id [/ip/dhcp-server/network/find where address=$networkAddress];

/ip/dhcp-server/network/set $id dns-server=$dnsServer;

/log/info "PIHOLE UP.";