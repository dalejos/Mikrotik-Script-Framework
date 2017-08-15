#Version: 2.0
#Fecha: 15-08-2017
#RouterOS 6.38
#Comentario:

:global setLastError;
:local lConfigName "config-module-pcc-init";

#TODO-BEGIN

:global gWanInterfaces;
:global gWanInterfaces \
{ \
    "WAN01"= \
    {\
        "DHCP"=true; \
        "IP"=""; \
        "Gateway"=""; \
        "EnableRouting"=false; \
        "RoutingMark"="to_wan1"; \
        "Distance"=1; \
        "PingTime"=""; \
        "LastInterfaceCheck"=""; \
        "LastRoutingCheck"=""; \
        "Status"=""
    }; \
    "WAN02"= \
    {\
        "DHCP"=true; \
        "IP"=""; \
        "Gateway"=""; \
        "EnableRouting"=false; \
        "RoutingMark"="to_wan2"; \
        "Distance"=2; \
        "PingTime"=""; \
        "LastInterfaceCheck"=""; \
        "LastRoutingCheck"=""; \
        "Status"=""
    }; \
    "WAN03"= \
    {\
        "DHCP"=true; \
        "IP"=""; \
        "Gateway"=""; \
        "EnableRouting"=false; \
        "RoutingMark"="to_wan3"; \
        "Distance"=3; \
        "PingTime"=""; \
        "LastInterfaceCheck"=""; \
        "LastRoutingCheck"=""; \
        "Status"=""
    }; \
    "WAN04"= \
    {\
        "DHCP"=true; \
        "IP"=""; \
        "Gateway"=""; \
        "EnableRouting"=false; \
        "RoutingMark"="to_wan4"; \
        "Distance"=4; \
        "PingTime"=""; \
        "LastInterfaceCheck"=""; \
        "LastRoutingCheck"=""; \
        "Status"=""
    } \
};

:global gPingHost;
:global gPingHost {"8.8.8.8";"8.8.4.4"};

:global gPingQoS;
:global gPingQoS \
{\
    "PingCount"=10; \
    "UmbralCount"=7; \
    "Size"=64; \
    "Timeout"="500ms"
};

#TODO-END

$setLastError 0 ("$lConfigName cargado.");