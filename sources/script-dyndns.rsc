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
:local lScritpName "script-dyndns";

:if ([$isScriptRuning $lScritpName]) do={
    $logWarning $lScritpName "Script corriendo.";
    return 255;
}

$setScriptStartRun $lScritpName;

#TODO-BEGIN

:global getFileContents;
:global gDynDNS;
:global getInterfaceIP;
:global resolveHost;

:local lLocalIp [$getInterfaceIP ($gDynDNS->"interface")];

:if ($lLocalIp != "0") do={
    :local lRemoteIP [$resolveHost ($gDynDNS->"host")];
    
    :if ($lRemoteIP != "0") do={
        :if ($lLocalIp != $lRemoteIP) do={
            $logInfo $lScritpName ("IP remota $lRemoteIP");
            $logInfo $lScritpName ("IP local: $lLocalIp");
            $logInfo $lScritpName ("Se necesita actualizar la IP, enviando actualizacion...!");
            
            :local lFetch false;
            :local lPath ("/nic/update?hostname=" . ($gDynDNS->"host") . "&myip=$lLocalIp&wildcard=NOCHG&mx=NOCHG&backmx=NOCHG");
            :local lFileName ("DynDNS." . ($gDynDNS->"host"));
            
            
            do {
                [/tool fetch address=members.dyndns.org src-path=$lPath mode=http user=($gDynDNS->"user") password=($gDynDNS->"password") dst-path="/$lFileName"];
                :set lFetch true;
            } on-error={
                $logError $lScritpName ("No se pudo enviar la actualizacion.");
            }
            :if ($lFetch) do={
                :local lContents [$getFileContents $lFileName];
                :if ($lContents = [:nothing]) do={
                    :set lContents "DynDNS ERROR: No se pudo obtener el contenido del archivo.";
                }
                :if ($lContents~"good") do={
                    $logInfo $lScritpName ("Resultado de la actualizacion $lContents");
                } else={
                    $logError $lScritpName ("Resultado de la actualizacion $lContents");
                }                
            }
        } else={
            $logInfo $lScritpName ("No se necesita realizar ningun cambio, IP: $lLocalIp");
        }
    } else={
        $logError $lScritpName ("No se pudo resolver el nombre de dominio " . ($gDynDNS->"host") . ".");
    }

} else={
    $logError $lScritpName ("No existe IP en interface " . ($gDynDNS->"interface") . ".");
}

#:delay 1
#:global str [/file find name="DynDNS.$ddnshost"];
#/file remove $str
#:global ipddns $ipfresh

#TODO-END

$setScriptEndRun $lScritpName;
