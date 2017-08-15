#Version: 2.0
#Fecha: 15-08-2017
#RouterOS 6.38
#Comentario: Inicializacion de RouterOS.

:global EMPTYARRAY [:toarray ""];

:global ISEMPTYARRAY do={
    :global EMPTYARRAY;
    :return ($1 = $EMPTYARRAY);
};

:global NOTHING [:nothing];

:global ISNOTHING do={
    :global NOTHING;
    :return ($1 = $NOTHING);
};

:global VERSION "2.0 beta";

:global lastError;
:set lastError {"Code"=0; "Msg"=""}

:global setLastError do={
    :global lastError;
    :set ($lastError->"Code") $1;
    :set ($lastError->"Msg") $2;
}

:global showLastError do={
    :global lastError;
    :put ("CODE: " . ($lastError->"Code"));
    :put ("MSG: " . ($lastError->"Msg"));
}

#Function loadConfig
#   Param:
#   $1: Script name
#
:global loadConfig do={
    :global ISEMPTYARRAY;
    :global setLastError;
    :global lastError;
    :local lScriptId [/system script find name=$1];
    
    $setLastError 1 ("Cargando $1...");
    :if (!([$ISEMPTYARRAY $lScriptId])) do={
        do {
            [/system script run $lScriptId];
            :if (($lastError->"Code") != 0) do={
                $setLastError 1 ("ERROR: No se pudo cargar $1.");
            }
        } on-error={
            $setLastError 1 ("ERROR: Ejecutando $1.");
        }
    } else={
        $setLastError 1 ("ERROR: $1 no instalado.");
    }
    :return ($lastError->"Code");
}

:local lLastErrorCode [$loadConfig "config-init"];

:if ($lLastErrorCode != 0) do={
    $showLastError;
    return $lLastErrorCode;
}

#Function setModuleStatusLoad
#   Param:
#   $1: Module name
#   $2: Load
#   $3: Status
#
:global setModuleStatusLoad do={
    :global gModules;
    :local lStatus $2;
    :local lLoad $3;
    
    :set ($gModules->"$1"->"Status") $lStatus;
    :if ([:len $lLoad] = 0) do={
        :set $lLoad false;
    }    
    :set ($gModules->"$1"->"Loaded") $lLoad;
}

:global setScriptInitRun do={
    :global gScripts;
    :local lCount [:tonum ($gScripts->"$1"->"InitRun")];
    :set lCount ($lCount + 1);
    :set ($gScripts->"$1"->"InitRun") $lCount;
}

:global setScriptRunCount do={
    :global gScripts;
    :local lCount [:tonum ($gScripts->"$1"->"RunCount")];
    :set lCount ($lCount + 1);
    :set ($gScripts->"$1"->"RunCount") $lCount;
}

:global showModuleStatus do={
    :global gModulesId;
    :global gModules;
    :put "";
    :foreach kModuleId,fModuleName in=$gModulesId do={
        :put "Modulo: $kModuleId - $fModuleName";
        :put ("Descripcion: " . ($gModules->"$fModuleName"->"Description"));
        :put ("Estado: " . ($gModules->"$fModuleName"->"Status"));
        :put "";
    }
}

:global showScriptStatus do={
    :global gScripts;
    :put "";
    :foreach kScript,fScript in=$gScripts do={
        :put "Script: $kScript";
        :put ("Descripcion: " . ($fScript->"Description"));
        :if ($fScript->"Enable") do={
            :put ("Init Run: " . ($fScript->"InitRun"));
            :put ("Run Count: " . ($fScript->"RunCount"));
            :put ("Intervalo de ejecucion: " . ($fScript->"Interval"));
            :put ("Status: " . ($fScript->"Status"));
        } else={
            :put "Script deshabilitado.";
        }
        :put "";
    }
}

#Cargar modulos

:local loadModules do={
    :global ISEMPTYARRAY;
    :global gModulesId;
    :global gModules;    
    :global setModuleStatusLoad;
    
    :foreach kModuleId,fModuleName in=$gModulesId do={        
        :if ($gModules->"$fModuleName"->"Enable") do={
            $setModuleStatusLoad $fModuleName ("Cargando modulo $fModuleName...");
            :local lScriptId [/system script find name=$fModuleName];
            :if (!([$ISEMPTYARRAY $lScriptId])) do={
                $setModuleStatusLoad $fModuleName ("ERROR: Modulo $fModuleName no informo haber cargado.");
                do {
                    [/system script run $lScriptId];
                } on-error={
                    $setModuleStatusLoad $fModuleName ("ERROR: Modulo $fModuleName no se pudo cargar (error de ejecucion).");
                }
            } else={
                $setModuleStatusLoad $fModuleName ("ERROR: Modulo $fModuleName no instalado.");
            }
        } else={
            $setModuleStatusLoad $fModuleName ("Modulo $fModuleName deshabilitado.");
        }
    }
}

#Cargar Script

:local scheduleScripts do={
    :global ISEMPTYARRAY;
    :global gScripts;
    
    :local setScriptStatus do={
        :global gScripts;
        :set ($gScripts->"$1"->"Status") $2;
    }
    
    :foreach kScript,fScript in=$gScripts do={
    
        :if ($fScript->"Enable") do={
            :local lScriptId [/system script find name=$kScript];
            
            :if (!([$ISEMPTYARRAY $lScriptId])) do={
                :local lSchedulerId ([/system scheduler find name=$kScript]);
                
                :if (([$ISEMPTYARRAY $lSchedulerId])) do={
                    $setScriptStatus $kScript ("Registrando script $kScript...");
                    [/system scheduler add comment=($fScript->"Description") \
                                           name=$kScript \
                                           on-event=$kScript \
                                           start-date=($fScript->"StartDate") \
                                           start-time=($fScript->"StartTime") \
                                           interval=($fScript->"Interval")];
                           
                    :set lScriptId [/system scheduler find name=$kScript];
                    
                    :if (!([$ISEMPTYARRAY $lScriptId])) do={
                        $setScriptStatus $kScript ("Script $kScript registrado.");
                    } else={
                        $setScriptStatus $kScript ("ERROR: Registrando script $kScript.");
                    }                        
                } else={
                    $setScriptStatus $kScript ("Script $kScript registrado.");
                    :local lScheduler ([/system scheduler get $lSchedulerId]);
                    
                    :if ($lScheduler->"interval" != $fScript->"Interval") do={
                        [/system scheduler set $lSchedulerId interva=($fScript->"Interval")];
                    }
                    :if ($lScheduler->"start-date" != $fScript->"StartDate") do={
                        [/system scheduler set $lSchedulerId start-date=($fScript->"StartDate")];
                    }
                    :if ($lScheduler->"start-time" != $fScript->"StartTime") do={
                        [/system scheduler set $lSchedulerId start-time=($fScript->"StartTime")];
                    }
                    :if ($lScheduler->"comment" != $fScript->"Description") do={
                        [/system scheduler set $lSchedulerId comment=($fScript->"Description")];
                    }
                }
            } else={
                $setScriptStatus $kScript ("ERROR: Script $kScript no instalado.");
            }
        } else={
            :local lSchedulerId ([/system scheduler find name=$kScript]);
            :if (!([$ISEMPTYARRAY $lSchedulerId])) do={
                [/system scheduler remove $lSchedulerId];
            }
        }
    }
}

$loadModules;
$scheduleScripts;