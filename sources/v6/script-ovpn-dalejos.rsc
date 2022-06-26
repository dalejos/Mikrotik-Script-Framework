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
:local lScritpName "script-ovpn-dalejos";

:if ([$isScriptRuning $lScritpName]) do={
    $logWarning $lScritpName "Script corriendo.";
    return 255;
}

$setScriptStartRun $lScritpName;

#TODO-BEGIN
:global generateTOTP;
:global getCurrentTimestamp;

:local pass [$generateTOTP "JKNHS6PZ37WYDBR2NWDLN36L4H7QGLAA" [$getCurrentTimestamp] 120];

/ppp secret set dalejos password=$pass;

#TODO-END

$setScriptEndRun $lScritpName;
