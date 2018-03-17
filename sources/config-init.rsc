#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario: Configuracion inicial de MSF.

:global setLastError;
:local lScriptName "config-init";

#TODO-BEGIN

:global gModules;
:set gModules \
{\
    "01"=\
    {\
        "name"="module-functions";\
        "enable"=true;\
        "loaded"=false;\
        "config"=false;\
        "description"="Funciones Generales."\
    };\
    "02"=\
    {\
        "name"="module-dyndns";\
        "enable"=false;\
        "loaded"=false;\
        "config"=true;\
        "description"="DynDNS Update."\
    };\
    "03"=\
    {\
        "name"="module-pcc-init";\
        "enable"=false;\
        "loaded"=false;\
        "config"=true;\
        "description"="Inicializacion de modulo de balanceo por PCC."\
    };\
    "04"=\
    {\
        "name"="module-geoip";\
        "enable"=true;\
        "loaded"=false;\
        "config"=false;\
        "description"="Herramienta para localizar IP geograficamente"\
    }\
}

:global gScripts;
:set gScripts \
{\
    "init"=\
    {\
        "startRun"=0;\
        "endRun"=0;\
        "enable"=true;\
        "startDate"="";\
        "startTime"="startup";\
        "interval"=0m;\
        "description"="Inicializacion del MSF."\
    };\
    "script-pcc-qos-wan"=\
    {\
        "startRun"=0;\
        "endRun"=0;\
        "enable"=true;\
        "startDate"="";\
        "startTime"="startup";\
        "interval"=10m;\
        "description"="PCC QoS para interfaces WAN."\
    };\
    "script-dyndns"=\
    {\
        "startRun"=0;\
        "endRun"=0;\
        "enable"=true;\
        "startDate"="";\
        "startTime"="startup";\
        "interval"=5m;\
        "description"="Dyndns Update."\
    }\
}

#TODO-END

$setLastError 0 ("$lScriptName cargado.");