/ip firewall filter

#Esta regla debe ir luego de las reglas INPUT que si aceptas
#Procesa los INPUT desde las lita de interface WAN y que no este en la lista
#secure_list
#Agrega a la lista secure_list tu red local.
add action=jump chain=input comment="lure input" connection-state=new \
    in-interface-list=WAN jump-target=lure_input src-address-list=\
    !secure_list
    

#Estas reglas pueden ir al final del filter    
add action=tarpit chain=lure_input comment="lure input BLACKLIST TCP TARPIT" \
    protocol=tcp src-address-list=lure_input_blacklist
add action=drop chain=lure_input comment="lure input BLACKLIST DROP" \
    src-address-list=lure_input_blacklist
add action=add-src-to-address-list address-list=lure_input_blacklist \
    address-list-timeout=none-static chain=lure_input comment=\
    "lure input BLACKLIST" log=yes log-prefix="LURE DROP -> "
add action=add-src-to-address-list address-list=lure_input_tcp_mikrotik \
    address-list-timeout=none-static chain=lure_input comment=\
    "lure input TCP MIKROTIK" dst-port=8728,8729,8291 protocol=tcp
add action=add-src-to-address-list address-list=lure_input_udp_mikrotik \
    address-list-timeout=none-static chain=lure_input comment=\
    "lure input UDP MIKROTIK" dst-port=2000 protocol=udp
add action=add-src-to-address-list address-list=lure_input_tcp \
    address-list-timeout=none-static chain=lure_input comment=\
    "lure input TCP" protocol=tcp
add action=add-src-to-address-list address-list=lure_input_udp \
    address-list-timeout=none-static chain=lure_input comment=\
    "lure input UDP" protocol=udp
