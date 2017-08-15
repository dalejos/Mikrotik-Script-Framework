#Version: 1.0
#Fecha: 20-04-2017
#RouterOS 6.38

/interface ethernet {
    set [ find default-name=ether1 ] comment="WAN 01" name=WAN01;
    set [ find default-name=ether2 ] comment="WAN 02" name=WAN02;
    set [ find default-name=ether3 ] comment="WAN 03" name=WAN03;
    set [ find default-name=ether4 ] comment="WAN 04" name=WAN04;
    set [ find default-name=ether5 ] comment="LAN 01" name=LAN01;
}

/ip dhcp-client {
    add dhcp-options=hostname,clientid disabled=no add-default-route=no interface=WAN01 comment="Cliente DHCP interface WAN01";
    add dhcp-options=hostname,clientid disabled=no add-default-route=no interface=WAN02 comment="Cliente DHCP interface WAN02";
    add dhcp-options=hostname,clientid disabled=no add-default-route=no interface=WAN03 comment="Cliente DHCP interface WAN03";
    add dhcp-options=hostname,clientid disabled=no add-default-route=no interface=WAN04 comment="Cliente DHCP interface WAN04";
}

/ip address {
    add address=192.168.1.1/24 network=192.168.1.0 interface=LAN01 comment="IP interface LAN01";
}

/ip pool {
    add name=DHCP_POOL_LAN01 ranges=192.168.1.101-192.168.1.199;
}

/ip dhcp-server {
    add address-pool=DHCP_POOL_LAN01 disabled=no interface=LAN01 name=DHCP_LAN01;
}

/ip dhcp-server network {
    add address=192.168.1.0/24 dns-server=8.8.8.8,8.8.4.4 gateway=192.168.1.1 comment="Parametros servidor DHCP interface LAN01";
}

/ip firewall nat {
    add chain=srcnat src-address=192.168.1.0/24 out-interface=WAN01 action=masquerade comment="Masquerade red local a WAN01";
    add chain=srcnat src-address=192.168.1.0/24 out-interface=WAN02 action=masquerade comment="Masquerade red local a WAN02";
    add chain=srcnat src-address=192.168.1.0/24 out-interface=WAN03 action=masquerade comment="Masquerade red local a WAN03";
    add chain=srcnat src-address=192.168.1.0/24 out-interface=WAN04 action=masquerade comment="Masquerade red local a WAN04";
}

/ip dns {
    set allow-remote-requests=yes cache-max-ttl=1w cache-size=2048KiB max-udp-packet-size=512 servers=8.8.8.8,8.8.4.4
}

/ip firewall mangle {
    #Gestionar Dinamicamente    
    add action=accept chain=prerouting comment=ID:WAN01 dst-address=127.0.0.0/24 in-interface=LAN01
    add action=accept chain=prerouting comment=ID:WAN02 dst-address=127.0.0.0/24 in-interface=LAN01
    add action=accept chain=prerouting comment=ID:WAN03 dst-address=127.0.0.0/24 in-interface=LAN01
    add action=accept chain=prerouting comment=ID:WAN04 dst-address=127.0.0.0/24 in-interface=LAN01

    add action=mark-connection chain=input comment="Marcar input wan1_conn" \
        in-interface=WAN01 new-connection-mark=wan1_conn passthrough=yes
    add action=mark-connection chain=input comment="Marcar input wan2_conn" \
        in-interface=WAN02 new-connection-mark=wan2_conn passthrough=yes
    add action=mark-connection chain=input comment="Marcar input wan3_conn" \
        in-interface=WAN03 new-connection-mark=wan3_conn passthrough=yes
    add action=mark-connection chain=input comment="Marcar input wan4_conn" \
        in-interface=WAN04 new-connection-mark=wan4_conn passthrough=yes
        
    add action=mark-routing chain=output comment="Marcar output to_wan1" \
        connection-mark=wan1_conn new-routing-mark=to_wan1
    add action=mark-routing chain=output comment="Marcar output to_wan2" \
        connection-mark=wan2_conn new-routing-mark=to_wan2
    add action=mark-routing chain=output comment="Marcar output to_wan3" \
        connection-mark=wan3_conn new-routing-mark=to_wan3
    add action=mark-routing chain=output comment="Marcar output to_wan4" \
        connection-mark=wan4_conn new-routing-mark=to_wan4
        
    add action=mark-connection chain=prerouting comment="PCC wan1_conn" \
        connection-mark=no-mark dst-address-type=!local in-interface=LAN01 \
        new-connection-mark=wan1_conn passthrough=yes per-connection-classifier=\
        both-addresses:4/0
    add action=mark-connection chain=prerouting comment="PCC wan2_conn" \
        connection-mark=no-mark dst-address-type=!local in-interface=LAN01 \
        new-connection-mark=wan2_conn passthrough=yes per-connection-classifier=\
        both-addresses:4/1
    add action=mark-connection chain=prerouting comment="PCC wan3_conn" \
        connection-mark=no-mark dst-address-type=!local in-interface=LAN01 \
        new-connection-mark=wan3_conn passthrough=yes per-connection-classifier=\
        both-addresses:4/2    
    add action=mark-connection chain=prerouting comment="PCC wan4_conn" \
        connection-mark=no-mark dst-address-type=!local in-interface=LAN01 \
        new-connection-mark=wan4_conn passthrough=yes per-connection-classifier=\
        both-addresses:4/3
        
    add action=mark-routing chain=prerouting comment="Marcar prerouting to_wan1" \
        connection-mark=wan1_conn in-interface=LAN01 new-routing-mark=to_wan1
    add action=mark-routing chain=prerouting comment="Marcar prerouting to_wan2" \
        connection-mark=wan2_conn in-interface=LAN01 new-routing-mark=to_wan2
    add action=mark-routing chain=prerouting comment="Marcar prerouting to_wan3" \
        connection-mark=wan3_conn in-interface=LAN01 new-routing-mark=to_wan3
    add action=mark-routing chain=prerouting comment="Marcar prerouting to_wan4" \
        connection-mark=wan4_conn in-interface=LAN01 new-routing-mark=to_wan4
        
    add action=mark-connection chain=prerouting comment=\
        "Marcar coneccion RDP wan1_nat" dst-port=44902 in-interface=\
        WAN01 new-connection-mark=wan1_nat passthrough=yes protocol=tcp
    add action=mark-routing chain=output comment=\
        "Rutear coneccion NATeada to_wan1" connection-mark=wan1_nat \
        new-routing-mark=to_wan1 passthrough=yes
}

#Gestionar Dinamicamente

/ip route {
    add gateway=WAN01 distance=1 check-gateway=ping comment="ID:WAN01";
    add gateway=WAN02 distance=2 check-gateway=ping comment="ID:WAN02";
    add gateway=WAN03 distance=3 check-gateway=ping comment="ID:WAN03";
    add gateway=WAN04 distance=4 check-gateway=ping comment="ID:WAN04";
    
    add dst-address=0.0.0.0/0 gateway=WAN01 routing-mark=to_wan1 check-gateway=ping comment="ID:WAN01";
    add dst-address=0.0.0.0/0 gateway=WAN02 routing-mark=to_wan2 check-gateway=ping comment="ID:WAN02";
    add dst-address=0.0.0.0/0 gateway=WAN03 routing-mark=to_wan3 check-gateway=ping comment="ID:WAN03";
    add dst-address=0.0.0.0/0 gateway=WAN04 routing-mark=to_wan4 check-gateway=ping comment="ID:WAN04";
}


