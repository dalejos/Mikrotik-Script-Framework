#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario:

:global setLastError;
:local lScriptName "config-module-dyndns";

#TODO-BEGIN

:global gDynDNS;
:global gDynDNS \
{ \
    "user"=""; \
    "password"=""; \
    "host"=""; \
    "interface"="WAN01"
};

#TODO-END

$setLastError 0 ("$lScriptName cargado.");