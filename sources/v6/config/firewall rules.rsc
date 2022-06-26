#Version: 3.0 alpha
#Fecha: 16-01-2018
#RouterOS 6.4x

#/ip firewall filter {
#    add chain=input action=accept protocol=icmp comment="Aceptar ICMP en todas las interfaces"
#    add chain=input action=accept connection-state=established,related comment="Aceptar conexiones con estado stablished, related"
#    
#    add chain=input action=accept in-interface=WAN01 dst-port=8291 protocol=tcp comment="Aceptar conexion al Mikrotik por la WAN01"
#    add chain=input action=drop in-interface=WAN01 comment="Rechazar los paquetes de la WAN01"
#    add chain=input action=drop in-interface=WAN02 comment="Rechazar los paquetes de la WAN02"
#    add chain=input action=drop in-interface=WAN03 comment="Rechazar los paquetes de la WAN03"
#    add chain=input action=drop in-interface=WAN04 comment="Rechazar los paquetes de la WAN04"
#    
#    add chain=forward action=accept connection-state=established,related comment="Aceptar conexiones con estado stablished, related"
#    add chain=forward action=drop connection-state=invalid comment="Rechazar paquetes invalidados."
#    add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface=WAN01 comment="Rechazar los paquetes de la WAN01 que no estan NATeados"
#}

/ip firewall filter {
    #input
    add action=accept chain=input comment="Aceptar conexiones con estado stablished, related" connection-state=established,related
    add action=accept chain=input comment="Aceptar conexion al Mikrotik por la WAN" dst-port=8291 in-interface-list=WAN protocol=tcp
    add action=accept chain=input comment="Aceptar ICMP en todas las interfaces" protocol=icmp
    add action=drop chain=input comment="Rechazar los paquetes de la WAN" in-interface-list=WAN
    
    #forward
    add action=accept chain=forward comment="Aceptar conexiones con estado stablished, related" connection-state=established,related
    add action=drop chain=forward comment="Rechazar paquetes invalidados." connection-state=invalid
    add action=drop chain=forward comment="Rechazar los paquetes de la WAN que no estan NATeados" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
}

/ip firewall nat {
    add action=dst-nat chain=dstnat in-interface=WAN01 protocol=tcp dst-port=3389 to-addresses=192.168.10.10 to-ports=3389
}

:put "OK...";