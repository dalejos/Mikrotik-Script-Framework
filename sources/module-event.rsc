#Version: 2.0
#Fecha: 15-08-2017
#RouterOS 6.38
#Comentario:

#:global loadConfig;
#:local lConfigName "config-module-";
:global setModuleStatusLoad;
:local lModuleName "module-event";

#:if (!([$loadConfig $lConfigName])) do={
#    $setModuleStatusLoad $lModuleName ("ERROR: En modulo $lModuleName cargando $lConfigName.");
#    return -1;
#}

#TODO-BEGIN

:global NOTHING;
:global ISNOTHING;

:global gDHCPClient;

:local init do={
    :global gDHCPClient;
    :set gDHCPClient ({});
    
    :local lIdClient [/ip dhcp-client find];
    
    :foreach fClient in=$lIdClient do={
        :local lClient [/ip dhcp-client get $fClient];
        :set ($gDHCPClient->($lClient->"interface")) ($lClient->"status"); 
    }
}

$init;

:put $gDHCPClient;

#TODO-END

$setModuleStatusLoad $lModuleName ("Modulo $lModuleName Cargado.") true;
