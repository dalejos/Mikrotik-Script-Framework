#Version: 2.0 beta
#Fecha: 20-04-2017
#RouterOS 6.38
#Comentario:

:global loadConfig;
:global setModuleStatusLoad;
:local lModuleName "module-pcc-init";
:local lConfigName "config-module-pcc-init";

:if ([$loadConfig $lConfigName] != 0) do={
    $setModuleStatusLoad $lModuleName ("ERROR: En modulo $lModuleName cargando $lConfigName.");
    return -1;
}

#TODO-BEGIN

:global gWanInterfaces;

#Function pingQoS
#   Param:
#   $1: Host
#   $2: Interface
#   $3: Routing Table
#
:global pingQoS;
:global pingQoS do={
    :global gPingQoS;
    :local lCount 0;
    
    :for i from=1 to=($gPingQoS->"PingCount") do={
        :set lCount ([/ping $1 interface $2 routing-table $3 count 1 interval ($gPingQoS->"Timeout") size ($gPingQoS->"Size")] + $lCount);
    }
    :return ($lCount >= $gPingQoS->"UmbralCount");
}

:foreach kWan,fInterface in=$gWanInterfaces do={
    [/ip route set [find comment="ID:$kWan"] disabled=yes];
}

#TODO-END

$setModuleStatusLoad $lModuleName ("Modulo $lModuleName Cargado.") true;

