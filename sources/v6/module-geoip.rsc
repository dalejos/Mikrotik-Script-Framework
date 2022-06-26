#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario: 

:global setLastError;
:local lScriptName "module-geoip";

#TODO-BEGIN

:global getGeoIP;
:global getGeoIP do={

    :global getFileContents;
    :global logInfo;
    :global logError;
    :global logWarning;

    :local lIP [:toip $1];
    :local result;
    
    :set result {"ip"="$lIP";\
                 "success"=false;\
                 "countryCode"="";\
                 "country"="";\
                 "msg"=""};
                 
    :local lFetch false;
    :local lUrl "http://ip-api.com/csv/$lIP?fields=status,country,countryCode,message,query";
    :local lFileName "geoip.csv";
    
    do {
        [/tool fetch url=$lUrl mode=http dst-path="/$lFileName"];
        :set lFetch true;
    } on-error={
        $logError $lScritpName ("Error realizando consulta Geo IP");
    }
    
    :if ($lFetch) do={
        :local lContents [$getFileContents $lFileName];
        :if ($lContents = [:nothing]) do={
            :set lContents "Geo IP ERROR: No se pudo obtener el contenido del archivo.";
        } else={
            :set lContents [:toarray $lContents];
            
            :if ([:typeof $lContents] = "array") do={
                :if ([:pick $lContents 0] = "success") do={
                    :set ($result->"success") true;                
                    :set ($result->"country") [:pick $lContents 1];
                    :set ($result->"countryCode") [:pick $lContents 2];
                    :set ($result->"ip") [:pick $lContents 3];
                } else={
                    :set ($result->"success") false;
                    :set ($result->"msg") [:pick $lContents 1];
                    :set ($result->"ip") [:pick $lContents 2];
                }
            } else={
            
            }
        }
    }    
        
    :return $result;    
}

#TODO-END

$setLastError 0 ("$lScriptName cargado.");