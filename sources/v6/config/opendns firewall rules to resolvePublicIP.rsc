#Haciendo una consulta DNS al dominio myip.opendns.com usando los DNS de opendns obtendremos
#la ip publica de la interface de salida.

#OpenDNS ofrece las siguientes direcciones de servidor de nombres de dominio (IPv4) para uso público:10​

#208.67.222.222 (OpenDNS Home Free/VIP)
#208.67.220.220 (OpenDNS Home Free/VIP)
#208.67.222.123 (OpenDNS FamilyShield) port 53, 443, 5353
#208.67.220.123 (OpenDNS FamilyShield) port 53, 443, 5353


/ip firewall address-list
add address=208.67.222.222 comment=RESOLVER1.OPENDNS.COM list=\
    RESOLVERS-OPENDNS
add address=208.67.220.220 comment=RESOLVER2.OPENDNS.COM list=\
    RESOLVERS-OPENDNS

/ip firewall mangle
add action=mark-routing chain=output comment=ID:RESOLVERS-OPENDNS \
    dst-address-list=RESOLVERS-OPENDNS dst-port=53 new-routing-mark=main \
    passthrough=no protocol=udp
    