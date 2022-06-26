#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario:

:global setLastError;
:local lScriptName "config-module-pcc-init";

#TODO-BEGIN

:global gWanInterfaces;
:set gWanInterfaces \
{\
    "WAN01"=\
    {\
        "dhcp"=true;\
        "ip"="";\
        "gateway"="";\
        "enableRouting"=false;\
        "routingMark"="to_wan1";\
        "distance"=1;\
        "pingTime"="";\
        "lastInterfaceCheck"="";\
        "lastRoutingCheck"="";\
        "status"=""\
    };\
    "WAN02"=\
    {\
        "dhcp"=true;\
        "ip"="";\
        "gateway"="";\
        "enableRouting"=false;\
        "routingMark"="to_wan2";\
        "distance"=1;\
        "pingTime"="";\
        "lastInterfaceCheck"="";\
        "lastRoutingCheck"="";\
        "status"=""\
    };\
    "WAN03"=\
    {\
        "dhcp"=true;\
        "ip"="";\
        "gateway"="";\
        "enableRouting"=false;\
        "routingMark"="to_wan3";\
        "distance"=1;\
        "pingTime"="";\
        "lastInterfaceCheck"="";\
        "lastRoutingCheck"="";\
        "status"=""\
    };\
    "WAN04"=\
    {\
        "dhcp"=true;\
        "ip"="";\
        "gateway"="";\
        "enableRouting"=false;\
        "routingMark"="to_wan4";\
        "distance"=1;\
        "pingTime"="";\
        "lastInterfaceCheck"="";\
        "lastRoutingCheck"="";\
        "status"=""\
    }\
}

:global gPingHost;
:set gPingHost \
{\
    "8.8.8.8";\
    "8.8.4.4"
}

:global gPingQoS;
:set gPingQoS \
{\
    "pingCount"=10;\
    "umbralCount"=7;\
    "size"=64;\
    "timeout"="500ms"
}

#TODO-END

$setLastError 0 ("$lScriptName cargado.");