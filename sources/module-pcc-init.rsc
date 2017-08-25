#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario: 

:global setLastError;
:local lScriptName "module-pcc-init";

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
    
    :for i from=1 to=($gPingQoS->"pingCount") do={
        :set lCount ([/ping $1 interface $2 routing-table $3 count 1 interval ($gPingQoS->"timeout") size ($gPingQoS->"size")] + $lCount);
    }
    :return ($lCount >= $gPingQoS->"umbralCount");
}

:foreach kWan,fInterface in=$gWanInterfaces do={
    [/ip route set [find comment="ID:$kWan"] disabled=yes];
}

#TODO-END

$setLastError 0 ("$lScriptName cargado.");