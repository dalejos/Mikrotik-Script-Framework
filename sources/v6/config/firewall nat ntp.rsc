/ip firewall nat
add action=masquerade chain=srcnat comment="NTP NAT" protocol=udp src-port=123 to-ports=10000-20000