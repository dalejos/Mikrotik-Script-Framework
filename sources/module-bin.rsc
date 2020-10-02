#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario: 

:global setLastError;
:local lScriptName "module-bin";

#TODO-BEGIN

:global numToBin;
:global numToBin do={
    :local num [:tonum $1];
    :local bin "";
    
    :if ([:typeof $num] = "num") do={
        :if ($num > 0) do={
            :while ($num > 0) do={
                :local bit ($num & 0x0000000000000001);
                :set bin ("$bit$bin");
                :set num ($num >> 1);
            }
        } else={
            :set bin "0";
        }
    }
    :return $bin;
}

#TODO-END

$setLastError 0 ("$lScriptName cargado.");