#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario: Inicializacion de MSF.

#Constante EMPTYARRAY
#   Descripcion: Representa un array vacio en MSF.
:global EMPTYARRAY [:toarray ""];

#Function isEmptyArray
#   Descripcion: Retorna si un array esta vacio o no.
#   Param:
#       $1: Un array.
#   Return: boolean.
#
:global isEmptyArray do={
    :global EMPTYARRAY;
    :return ($1 = $EMPTYARRAY);
}

#Constante NOTHING
#   Descripcion: Representa el valor de una variable vacia en MSF.
:global NOTHING [:nothing];

#Function isNothing
#   Descripcion: Retorna si una variable esta vacia o no.
#   Param:
#       $1: Una variable.
#   Return: boolean.
#   

:global isNothing do={
    :global NOTHING;
    :return ($1 = $NOTHING);
}

#Constante MSFVERSION
#   Descripcion: Version del MSF.
:global MSFVERSION "3.0 alpha";

#Constante ROSVERSION
#   Descripcion: Version minima de RouterOS para ejecutar MSF.
:global ROSVERSION "6.40";

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

:global logInfo do={
    :log info message="$1 - $2";
}

:global logWarning do={
    :log warning message="$1 - $2";
}

:global logError do={
    :log error message="$1 - $2";
}

:global logDebug do={
    :log debug message="$1 - $2";
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

#Function setModuleLoaded
#   Param:
#   $1: Id del modulo
#
:global setModuleLoaded do={
    :global gModules;    
    :set ($gModules->"$1"->"loaded") true;
}

#Cargar modulos

:local loadModules do={
    :global gModules;    
    :global logInfo;
    :global logError;
    :global lastError;
    :global loadScript;
    :local lScriptName "init.loadModules";
    :local lErrorCode;
    
    :foreach kModuleId,fModule in=$gModules do={
    
        :if ($fModule->"enable") do={
            :set lErrorCode 0;
            
            :if ($fModule->"config") do={
                :set lErrorCode [$loadScript ("config-" . ($fModule->"name"))];

                :if ($lErrorCode != 0) do={
                    $logError $lScriptName (($fModule->"name") . " - " .($lastError->"msg"));
                } else={
                    $logInfo $lScriptName ($lastError->"msg");
                }
            }
            
            :if ($lErrorCode = 0) do={
                :set lErrorCode [$loadScript ($fModule->"name")];

                :if ($lErrorCode != 0) do={
                    $logError $lScriptName ($lastError->"msg");
                } else={
                    :set ($gModules->"$kModuleId"->"loaded") true;
                    $logInfo $lScriptName ($lastError->"msg");
                }            
            }            
        }
    }
}

#Function scheduleScripts

:local scheduleScripts do={
    :global isEmptyArray;
    :global gScripts;
    :global logInfo;
    :global logError;
    :local lScriptName "init.scheduleScripts";
    
    :foreach kScript,fScript in=$gScripts do={
    
        :if ($fScript->"enable") do={
            :local lScriptId [/system script find name=$kScript];
            
            :if (!([$isEmptyArray $lScriptId])) do={
                :local lSchedulerId ([/system scheduler find name=$kScript]);
                
                :if (([$isEmptyArray $lSchedulerId])) do={
                    $logInfo $lScriptName ("Registrando script $kScript...");
                    [/system scheduler add comment=($fScript->"description") \
                                           name=$kScript \
                                           on-event=$kScript \
                                           start-date=($fScript->"startDate") \
                                           start-time=($fScript->"startTime") \
                                           interval=($fScript->"interval")];
                           
                    :set lScriptId [/system scheduler find name=$kScript];
                    
                    :if (!([$isEmptyArray $lScriptId])) do={
                        $logInfo $lScriptName ("Script $kScript registrado.");
                    } else={
                        $logError $lScriptName ("Registrando script $kScript.");
                    }                        
                } else={
                    $logInfo $lScriptName ("Script $kScript registrado.");
                    :local lScheduler ([/system scheduler get $lSchedulerId]);
                    
                    :if ($lScheduler->"interval" != $fScript->"interval") do={
                        [/system scheduler set $lSchedulerId interva=($fScript->"interval")];
                    }
                    :if ($lScheduler->"start-date" != $fScript->"startDate") do={
                        [/system scheduler set $lSchedulerId start-date=($fScript->"startDate")];
                    }
                    :if ($lScheduler->"start-time" != $fScript->"startTime") do={
                        [/system scheduler set $lSchedulerId start-time=($fScript->"startTime")];
                    }
                    :if ($lScheduler->"comment" != $fScript->"description") do={
                        [/system scheduler set $lSchedulerId comment=($fScript->"description")];
                    }
                }
            } else={
                $logError $lScriptName ("Script $kScript no instalado.");
            }
        } else={
            :local lSchedulerId ([/system scheduler find name=$kScript]);
            :if (!([$isEmptyArray $lSchedulerId])) do={
                [/system scheduler remove $lSchedulerId];
                $logInfo $lScriptName ("Script $kScript removido.");
            } else={
                $logInfo $lScriptName ("Script $kScript deshabilitado.");
            }
        }
    }
}

#Function scheduleScripts

:global setScriptStartRun do={
    :global gScripts;
    :local lCount [:tonum ($gScripts->"$1"->"startRun")];
    :set lCount ($lCount + 1);
    :set ($gScripts->"$1"->"startRun") $lCount;
}

#Function scheduleScripts

:global setScriptEndRun do={
    :global gScripts;
    :local lCount [:tonum ($gScripts->"$1"->"endRun")];
    :set lCount ($lCount + 1);
    :set ($gScripts->"$1"->"endRun") $lCount;
}


do {
#TODO-BEGIN

:local lScriptName "init";
:local lConfigName "config-init";

:local lErrorCode [$loadScript $lConfigName];

:if ($lErrorCode != 0) do={
    $logError $lScriptName ($lastError->"msg");
    :return $lErrorCode;
} else={
    $logInfo $lScriptName ($lastError->"msg");
}

$loadModules;
$scheduleScripts;

#TODO-END

    $logInfo $lScriptName "MSF cargado.";
} on-error={
    $logError $lScriptName "ERROR Cargando MSF.";
}