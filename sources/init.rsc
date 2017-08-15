#Version: 1.0
#Fecha: 20-04-2017
#RouterOS 6.38
#Comentario: Inicializacion de RouterOS.

:global gConfig;
:global gConfig \
{ \
    "Status"=""; \
    "Loaded"=false
};

#Function loadConfig
#   Param:
#   $1: Script name
#
:global loadConfig;
:global loadConfig do={
    
    :global gConfig;
    :set ($gConfig->"Status") "Cargando $1...";
    :set ($gConfig->"Loaded") false;
    :local lExists ([:len [/system script find name=$1]] = 1);
    :if ($lExists) do={
        do {
            [/system script run $1];
        } on-error={
            :set ($gConfig->"Status") "ERROR: Ejecutando $1.";
        }
    } else={
        :set ($gConfig->"Status") "ERROR: $1 no instalado.";
    }
    :if (!($gConfig->"Loaded")) do={
        :set ($gConfig->"Status") "ERROR: No se pudo cargar $1.";
    }
    :return ($gConfig->"Loaded");
};

:if (!([$loadConfig "config-init"])) do={
    return -1;
}

#Function setModuleStatusLoad
#   Param:
#   $1: Module name
#   $2: Load
#   $3: Status
#
:global setModuleStatusLoad;
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

:global setScriptInitRun;
:global setScriptInitRun do={
    :global gScripts;
    :local lCount [:tonum ($gScripts->"$1"->"InitRun")];
    :set lCount ($lCount + 1);
    :set ($gScripts->"$1"->"InitRun") $lCount;
}

:global setScriptRunCount;
:global setScriptRunCount do={
    :global gScripts;
    :local lCount [:tonum ($gScripts->"$1"->"RunCount")];
    :set lCount ($lCount + 1);
    :set ($gScripts->"$1"->"RunCount") $lCount;
}

:global showModuleStatus;
:global showModuleStatus do={
    :global gModules;
    :put "";
    :foreach kModule,fModule in=$gModules do={
        :put "Modulo: $kModule";
        :put ("Descripcion: " . ($fModule->"Description"));
        :put ("Estado: " . ($fModule->"Status"));
        :put "";
    }
}

:global showScriptStatus;
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
    :global gModules;    
    :global setModuleStatusLoad;
    
    :foreach kModule,fModule in=$gModules do={
        :local lExists ([:len [/system script find name=$kModule]] = 1);
        
        :if ($fModule->"Enable") do={
            $setModuleStatusLoad $kModule ("Cargando modulo $kModule...");
            :if ($lExists) do={
                $setModuleStatusLoad $kModule ("ERROR: Modulo $kModule no informo haber cargado.");
                do {
                    [/system script run $kModule];
                } on-error={
                    $setModuleStatusLoad $kModule ("ERROR: Modulo $kModule no se pudo cargar (error de ejecucion).");
                }
            } else={
                $setModuleStatusLoad $kModule ("ERROR: Modulo $kModule no instalado.");
            }
        } else={
            $setModuleStatusLoad $kModule ("Modulo $kModule deshabilitado.");
        }
    }    
}

:local scheduleScripts do={
    :global gScripts;
    
    :local setScriptStatus do={
        :global gScripts;
        :set ($gScripts->"$1"->"Status") $2;
    }
    
    :foreach kScript,fScript in=$gScripts do={
    
        :if ($fScript->"Enable") do={
            :local lScriptExists ([:len [/system script find name=$kScript]] = 1);
            
            :if ($lScriptExists) do={
                :local lSchedulerId ([/system scheduler find name=$kScript]);
                
                :if ([:len $lSchedulerId] = 0) do={
                    $setScriptStatus $kScript ("Registrando script $kScript...");
                    [/system scheduler add comment=($fScript->"Description") \
                                           name=$kScript \
                                           on-event=$kScript \
                                           start-date=($fScript->"StartDate") \
                                           start-time=($fScript->"StartTime") \
                                           interval=($fScript->"Interval")];
                           
                    :local lRegister ([:len [/system scheduler find name=$kScript]] = 1);
                    
                    :if ($lRegister) do={
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
            :if ([:len $lSchedulerId] > 0) do={
                [/system scheduler remove $lSchedulerId];
            }
        }
    }
}

:delay 1s;
$loadModules;
$scheduleScripts;