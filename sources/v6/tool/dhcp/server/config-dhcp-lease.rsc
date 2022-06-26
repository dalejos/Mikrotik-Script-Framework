:global dhcpLeaseConfig;
:set dhcpLeaseConfig [:toarray ""];

#Segmento de red del DHCP server, tipo ip-prefix.
:set ($dhcpLeaseConfig->"net") 192.168.88.0/24;

#Filtro MAC para no procesar dispositivos cuyas MAC esten en esta lista, tipo array de str.
:set ($dhcpLeaseConfig->"filterMAC") {"70:71:BC:AD:4D:DC"; "CE:E0:E0:5D:EB:A0"};

#Nombre del DHCP server, tipo str.
:set ($dhcpLeaseConfig->"dhcpServer") "defconf";

#Tiempo por defecto del lease-time del servidor DHCP expresado en minutos, se recomienda un valor entre 5m y 10m, tipo time.
:set ($dhcpLeaseConfig->"dhcpLeaseTime") 10m;

#Tiempo de desbloqueo por defecto, expresa el tiempo en segundos; 60 * 60 (una hora), tipo num.
:set ($dhcpLeaseConfig->"unlockedTime") (60 * 60);

#Tiempo de bloqueo por defecto, expresa el tiempo en segundos; 60 * 60 (una hora), tipo num.
:set ($dhcpLeaseConfig->"lockedTime") (60 * 60);