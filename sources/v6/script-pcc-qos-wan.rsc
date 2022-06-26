#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario:

:global isScriptRuning;
:global setScriptStartRun;
:global setScriptEndRun;
:global logInfo;
:global logError;
:global logWarning;
:local lScritpName "script-pcc-qos-wan";

:if ([$isScriptRuning $lScritpName]) do={
    $logWarning $lScritpName "Script corriendo.";
    return 255;
}

$setScriptStartRun $lScritpName;

#TODO-BEGIN

:global gWanInterfaces;
:global getNetAddress;
:global gPingHost;
:global pingQoS;

:foreach kWan,fInterface in=$gWanInterfaces do={
    
    :local lGateway ($fInterface->"gateway");
    :local lAddress;
    
    $logInfo $lScritpName ("Chequeando interface $kWan");
    
    :if ($fInterface->"dhcp") do={
        :local lDhcpId [/ip dhcp-client find interface=$kWan];
        :if ([:len $lDhcpId] > 0) do={
            :set lGateway [/ip dhcp-client get $lDhcpId gateway];
            :set lAddress [/ip dhcp-client get $lDhcpId address];
        }
    } else={
        :set lAddress [/ip address get [find interface=$kWan] address];
    }
    
    :set lGateway [:toip $lGateway];
    
    :if ([:len $lGateway] > 0) do={
        :local lQoS false;
        $logInfo $lScritpName ("$kWan gateway: $lGateway");
        [/ip route set [find comment="ID:$kWan"] gateway="$lGateway%$kWan"];
        
        :local lNetAddress [$getNetAddress $lAddress]
        [/ip firewall mangle set [find comment="ID:$kWan"] dst-address=$lNetAddress];
        
        :if ( !($fInterface->"enableRouting")) do={
            $logInfo $lScritpName ("Iniciando ping al gateway $lGateway...");
            :set lQoS ([$pingQoS $lGateway $kWan "main"]);
            $logInfo $lScritpName ("QoS: $lQoS");
            :if ($lQoS) do={
                [/ip route set [find comment="ID:$kWan"] disabled=no];
                :delay 3s;
                #Revisar para actializar
                #:foreach fHost in=$gPingHost do={
                #    :set lQoS ([$pingQoS $fHost $kWan ($fInterface->"RoutingMark")]);
                #}
                $logInfo $lScritpName ("Iniciando ping a 8.8.8.8...");
                :set lQoS ([$pingQoS "8.8.8.8" $kWan ($fInterface->"routingMark")]);
                $logInfo $lScritpName ("QoS: $lQoS");
                :if ($lQoS) do={
                    :set ($fInterface->"enableRouting") true;
                } else={
                    [/ip route set [find comment="ID:$kWan"] disabled=yes];
                }
            }
        } else={
            $logInfo $lScritpName ("Iniciando ping a 8.8.8.8...");
            :set lQoS ([$pingQoS "8.8.8.8" $kWan ($fInterface->"routingMark")]);
            $logInfo $lScritpName ("QoS: $lQoS");
            :if ( !($lQoS)) do={
                [/ip route set [find comment="ID:$kWan"] disabled=yes];
                :set ($fInterface->"enableRouting") false;
            }
        }
    } else={
        [/ip route set [find comment="ID:$kWan"] disabled=yes];
        $logWarning $lScritpName ("Gateway no encontrado, deshabilitando ruta ID:$kWan");
    }
}

#TODO-END

$setScriptEndRun $lScritpName;
