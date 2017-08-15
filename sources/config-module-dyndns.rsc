#Version: 2.0 beta
#Fecha: 20-04-2017
#RouterOS 6.38
#Comentario:

:global setLastError;
:local lConfigName "config-module-dyndns";

#TODO-BEGIN

:global gDynDNS;
:global gDynDNS \
{ \
    "User"=""; \
    "Password"=""; \
    "Host"=""; \
    "Interface"="WAN01"
};

#TODO-END

$setLastError 0 ("$lConfigName cargado.");