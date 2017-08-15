#Version: 1.0
#Fecha: 20-04-2017
#RouterOS 6.38
#Comentario:

:global gConfig;

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

:set ($gConfig->"Loaded") true;
