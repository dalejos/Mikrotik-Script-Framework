#Version: 3.0 alpha
#Fecha: 25-03-2018
#RouterOS 6.40 y superior.
#Comentario: Instalacion de MSF.

#Array lastError
#   Descripcion: Estructura para el paso de errores entre ejecucion de scripts en MSF.
#   Keys:
#       code: Codigo de error.
#       msg: Mensaje de error.
:global lastError;
:set lastError {"code"=0; "msg"=""};

#Function setLastError
#   Descripcion: Establece los valores para el array lastError.
#   Param:
#       $1: Codigo de error.
#       $2: Mensaje de error.
#   Return:
:global setLastError do={
    :global lastError;
    :set ($lastError->"code") $1;
    :set ($lastError->"msg") "$2 (codigo $1).";
}

#Function loadScript
#   Descripcion: Carga un script de configuracion.
#   Param:
#      $1: nombre del script.
#
:global loadScript do={
    :global isEmptyArray;
    :global setLastError;
    :global lastError;
    :local lScriptId [/system script find name=$1];
    
    $setLastError 1 ("Cargando $1...");
    :if (!([$isEmptyArray $lScriptId])) do={
        do {
            [/system script run $lScriptId];
            :if (($lastError->"code") != 0) do={
                $setLastError 2 ("No se pudo cargar $1");
            }
        } on-error={
            $setLastError 3 ("Ejecutando $1");
        }
    } else={
        $setLastError 4 ("No se ha instalado $1");
    }
    :return ($lastError->"code");
}

do {
#TODO-BEGIN

:local files [/file find where name~"msf/"];

:foreach id in=$files do={
    :local f [/file get $id];
    :local name ($f->"name");
    :set name [:pick $name ([:find $name "/"] + 1) [:len $name]];
    :set name [:pick $name 0 [:find $name "."]];
    :put "Instalando $name...";
    /system script add name=$name source=($f->"contents");
}

#:local lScriptName "init";
#:local lConfigName "config-init";

#:local lErrorCode [$loadScript $lConfigName];

#:if ($lErrorCode != 0) do={
#    $logError $lScriptName ($lastError->"msg");
#    :return $lErrorCode;
#} else={
#    $logInfo $lScriptName ($lastError->"msg");
#}

#TODO-END

    :put "$lScriptName MSF instalado.";
} on-error={
    :put "$lScriptName ERROR instalando MSF.";
}