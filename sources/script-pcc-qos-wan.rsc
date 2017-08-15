#Version: 1.0
#Fecha: 20-04-2017
#RouterOS 6.38
#Comentario:

:global isScriptRun;
:global setScriptInitRun;
:global setScriptRunCount;
:local lScritpName "script-pcc-qos-wan";

:if ([$isScriptRun $lScritpName]) do={
    return 255;
}

$setScriptInitRun $lScritpName;

#TODO-BEGIN

:global gWanInterfaces;
:global getNetAddress;
:global gPingHost;
:global pingQoS;

:foreach kWan,fInterface in=$gWanInterfaces do={
    
    :local lGateway ($fInterface->"Gateway");
    :local lAddress;
    
    :if ($fInterface->"DHCP") do={
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
        :put "$kWan Gateway: $lGateway";
        [/ip route set [find comment="ID:$kWan"] gateway="$lGateway%$kWan"];
        
        :local lNetAddress [$getNetAddress $lAddress]
        [/ip firewall mangle set [find comment="ID:$kWan"] dst-address=$lNetAddress];
        
        :if ( !($fInterface->"EnableRouting")) do={
            :put "Iniciando ping al gateway $lGateway...";
            :set lQoS ([$pingQoS $lGateway $kWan "main"]);
            :put "QoS: $lQoS";
            :if ($lQoS) do={
                [/ip route set [find comment="ID:$kWan"] disabled=no];
                :delay 3s;
                #Revisar para actializar
                #:foreach fHost in=$gPingHost do={
                #    :set lQoS ([$pingQoS $fHost $kWan ($fInterface->"RoutingMark")]);
                #}
                :put "Iniciando ping a 8.8.8.8...";
                :set lQoS ([$pingQoS "8.8.8.8" $kWan ($fInterface->"RoutingMark")]);
                :put "QoS: $lQoS";
                :if ($lQoS) do={
                    :set ($fInterface->"EnableRouting") true;
                } else={
                    [/ip route set [find comment="ID:$kWan"] disabled=yes];
                }
            }
        } else={
            :put "Iniciando ping a 8.8.8.8...";
            :set lQoS ([$pingQoS "8.8.8.8" $kWan ($fInterface->"RoutingMark")]);
            :put "QoS: $lQoS";
            :if ( !($lQoS)) do={
                [/ip route set [find comment="ID:$kWan"] disabled=yes];
                :set ($fInterface->"EnableRouting") false;
            }
        }
    }
}


#TODO-END

$setScriptRunCount $lScritpName;

