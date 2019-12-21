/ip firewall address-list
add address=208.67.222.222 comment=RESOLVER1.OPENDNS.COM list=\
    RESOLVERS-OPENDNS
add address=208.67.220.220 comment=RESOLVER2.OPENDNS.COM list=\
    RESOLVERS-OPENDNS

/ip firewall mangle
add action=mark-routing chain=output comment=ID:RESOLVERS-OPENDNS \
    dst-address-list=RESOLVERS-OPENDNS dst-port=53 new-routing-mark=main \
    passthrough=no protocol=udp
    