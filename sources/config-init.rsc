#Version: 2.0
#Fecha: 15-08-2017
#RouterOS 6.38.5
#Comentario:

:global setLastError;
:local lConfigName "config-init";

#TODO-BEGIN

:global gModulesId;
:set gModulesId \
{ \
    "01"="module-functions"; \
    "02"="module-dyndns"; \
    "03"="module-pcc-init" \
};

:global gModules;
:set gModules \
{ \
    "module-functions"= \
    {\
        "Description"="Funciones Generales."; \
        "Loaded"=false; \
        "Enable"=true; \
        "Status"=""
    }; \
    "module-dyndns"= \
    {\
        "Description"="DynDNS Update."; \
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
}

:global gScripts;
:set gScripts \
{ \
    "init"=\
    {\
        "Description"="Inicializacion del MSF."; \
        "InitRun"=0; \
        "RunCount"=0; \
        "Enable"=true; \
        "StartDate"=""; \
        "StartTime"="startup"; \
        "Interval"=0m; \
        "Status"=""        
    }; \
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
}

#TODO-END

$setLastError 0 ("$lConfigName cargado.");