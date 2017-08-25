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
:local lScritpName "script-";

:if ([$isScriptRuning $lScritpName]) do={
    $logWarning $lScritpName "Script corriendo.";
    return 255;
}

$setScriptStartRun $lScritpName;

#TODO-BEGIN

#TODO-END

$setScriptEndRun $lScritpName;
