:global monitorTrafficConfig;
:set monitorTrafficConfig [:toarray ""];

:global monitorTrafficData;
:set monitorTrafficData [:toarray ""];

#Intervalo de tiempo para el monitoreo.
:set ($monitorTrafficConfig->"interval") 1s;

#Duracion del monitoreo.
:set ($monitorTrafficConfig->"duration") 1m;

#Tiempo de espera antes de monitorear luego de hacer un UP.
:set ($monitorTrafficConfig->"delayForUp") 30s;

#Lista de interfaces a monitorear.
:set ($monitorTrafficConfig->"interfaces") [:toarray ""];

:set ($monitorTrafficConfig->"interfaces"->"ether1-wan") {"rx-average"=1024; "up"="ether1-wan-up"; "down"="ether1-wan-down"};
:set ($monitorTrafficConfig->"interfaces"->"ether2") {"rx-average"=2048; "up"=""; "down"=""};