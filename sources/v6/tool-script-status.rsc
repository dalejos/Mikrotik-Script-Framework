#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario:

#TODO-BEGIN

:global gScripts;
:put "";
:put "########## Script Status ##########";
:put "";
:foreach kScript,fScript in=$gScripts do={
    :put "Script: $kScript";
    :put ("Descripcion: " . ($fScript->"description"));
    :if ($fScript->"enable") do={
        :put ("Nro. veces ejecutado: " . ($fScript->"startRun"));
        :put ("Nro. veces ejecucion terminada: " . ($fScript->"endRun"));
        :put ("Intervalo de ejecucion: " . ($fScript->"interval"));
    } else={
        :put "Script deshabilitado.";
    }
    :put "";
}

#TODO-END
