#Version: 2.0 beta
#Fecha: 20-04-2017
#RouterOS 6.38
#Comentario:

:global isScriptRun;
:global setScriptInitRun;
:global setScriptRunCount;
:local lScritpName "script-";

:if ([$isScriptRun $lScritpName]) do={
    return 255;
}

$setScriptInitRun $lScritpName;

#TODO-BEGIN

#TODO-END

$setScriptRunCount $lScritpName;

