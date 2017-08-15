#Version: 2.0
#Fecha: 15-08-2017
#RouterOS 6.38
#Comentario:

:global isScriptRun;
:global setScriptInitRun;
:global setScriptRunCount;
:local lScritpName "script-dyndns";

:if ([$isScriptRun $lScritpName]) do={
    return 255;
}

$setScriptInitRun $lScritpName;

#TODO-BEGIN

:global getFileContents;
:global gDynDNS;
:global getInterfaceIP;
:global resolveHost;

:local lLocalIp [$getInterfaceIP ($gDynDNS->"Interface")];

:if ($lLocalIp != "0") do={
    :local lRemoteIP [$resolveHost ($gDynDNS->"Host")];
    
    :if ($lRemoteIP != "0") do={
        :if ($lLocalIp != $lRemoteIP) do={
            :log info "DynDNS: IP Remota: $lRemoteIP";
            :log info "DynDNS: IP Local: $lLocalIp";
            :log info "DynDNS: Se necesita actualizar la IP, enviando actualizacion...!";
            
            :local lFetch false;
            :local lPath ("/nic/update?hostname=" . ($gDynDNS->"Host") . "&myip=$lLocalIp&wildcard=NOCHG&mx=NOCHG&backmx=NOCHG");
            :local lFileName ("DynDNS." . ($gDynDNS->"Host"));
            
            
            do {
                [/tool fetch address=members.dyndns.org src-path=$lPath mode=http user=($gDynDNS->"User") password=($gDynDNS->"Password") dst-path="/$lFileName"];
                :set lFetch true;
            } on-error={
                :log info "DynDNS ERROR: enviando actualizacion.";
            }
            :if ($lFetch) do={
                :local lContents [$getFileContents $lFileName];
                :if ($lContents = [:nothing]) do={
                    :set lContents "DynDNS ERROR: No se pudo obtener el contenido del archivo.";
                }
                :if ($lContents~"good") do={
                    :log info "DynDNS: $lContents";
                } else={
                    :log info "DynDNS: ERROR $lContents";
                }                
            }
        } else={
            :log info "DynDNS: No se necesita realizar ningun cambio, IP: $lLocalIp";
        }
    } else={
        :log info ("DynDNS: No se pudo resolver el nombre de dominio " . ($gDynDNS->"Host") . ".");
    }

} else={
    :log info ("DynDNS: No existe IP en interface " . ($gDynDNS->"Interface") . ".");
}

#:delay 1
#:global str [/file find name="DynDNS.$ddnshost"];
#/file remove $str
#:global ipddns $ipfresh

#TODO-END

$setScriptRunCount $lScritpName;
