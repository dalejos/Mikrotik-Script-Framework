#Version: 1.0
#Fecha: 20-04-2017
#RouterOS 6.38

/ip firewall filter {
    add chain=input action=accept protocol=icmp comment="Aceptar ICMP en todas las interfaces"
    add chain=input action=accept connection-state=established,related comment="Aceptar conexiones con estado stablished, related"
    
    add chain=input action=accept in-interface=WAN01 dst-port=8291 protocol=tcp comment="Aceptar conexion al Mikrotik por la WAN01"
    add chain=input action=drop in-interface=WAN01 comment="Rechazar los paquetes de la WAN01"
    add chain=input action=drop in-interface=WAN02 comment="Rechazar los paquetes de la WAN02"
    add chain=input action=drop in-interface=WAN03 comment="Rechazar los paquetes de la WAN03"
    add chain=input action=drop in-interface=WAN04 comment="Rechazar los paquetes de la WAN04"
    
    add chain=forward action=fasttrack-connection connection-state=established,related comment="Usar fasttrack"
    add chain=forward action=accept connection-state=established,related comment="Aceptar conexiones con estado stablished, related"
    add chain=forward action=drop connection-state=invalid comment="Rechazar paquetes invalidados."
    add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface=WAN01 comment="Rechazar los paquetes de la WAN01 que no estan NATeados"
    
}

/ip firewall nat {
    add action=dst-nat chain=dstnat in-interface=WAN01 protocol=tcp dst-port=8291 to-addresses=192.168.50.1 to-ports=8291
}
