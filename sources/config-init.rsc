#Version: 1.0
#Fecha: 20-04-2017
#RouterOS 6.38
#Comentario:

:global gConfig;

#TODO-BEGIN

:global gModules;
:global gModules \
{ \
    "module-dyndns"= \
    {\
        "Description"="DynDNS Update."; \
        "Loaded"=false; \
        "Enable"=true; \
        "Status"=""
    }; \
    "module-functions"= \
    {\
        "Description"="Funciones Generales."; \
        "Loaded"=false; \
        "Enable"=true; \
        "Status"=""
    }; \
    "module-pcc-init"= \
    {\
        "Description"="Inicializacion de modulo de balanceo por PCC."; \
        "Loaded"=false; \
        "Enable"=true; \
        "Status"=""
    } \
};

:global gScripts;
:global gScripts \
{ \
    "script-pcc-qos-wan"= \
    {\
        "Description"="PCC QoS para interfaces WAN."; \
        "InitRun"=0; \
        "RunCount"=0; \
        "Enable"=true; \
        "StartDate"=""; \
        "StartTime"="startup"; \
        "Interval"=10m; \
        "Status"=""
    }; \
    "script-dyndns"= \
    {\
        "Description"="Dyndns Update."; \
        "InitRun"=0; \
        "RunCount"=0; \
        "Enable"=true; \
        "StartDate"=""; \
        "StartTime"="startup"; \
        "Interval"=5m; \
        "Status"=""
    } \
};

#TODO-END

:set ($gConfig->"Loaded") true;
