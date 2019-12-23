#Version: 3.0 alpha
#Fecha: 22-12-2019
#RouterOS 6.43 y superior.
#Comentario: 

#TODO-BEGIN

:local format;
:local format do={
    :local src $1;
    :local length $2;
    :local lengthSrc [:len $src];
    
    :if ($lengthSrc < $length) do={
        :for index from=$lengthSrc to=$length do={
            :set src ($src . " ");
        }
    }
    :return $src;
}


:local dstAddress ({});

:local connections [/ip firewall connection find];
:local length [:len $connections];

:for index from=0 to=($length - 1) do={ 
    :local conn ($connections->$index);
    :local dstIp [/ip firewall connection get $conn dst-address];
    
    :local doubleDot [:find $dstIp ":"];
    
    :if ( $doubleDot > 0) do={ 
        :set dstIp [:pick $dstIp 0 $doubleDot];
    }
    
    :set dstAddress ($dstAddress, $dstIp);
}

:put "";
:put ([$format "#" 4] . [$format "IP" 16] . [$format "COUNTRY" 10] . [$format "COUNTRY NAME" 25] . [$format "AS NAME" 30]);

:local idx 0;
:local request 0;
:foreach dstIp in=$dstAddress do={
    :local lUrl "http://ip-api.com/csv/$dstIp?fields=status,message,country,countryCode,as,asname,query";
    :local result;
    :if ($request > 39) do={
        :set request 0;
        :delay 20;
    }
    do {
        :set result [/tool fetch url=$lUrl mode=http as-value output=user];
        :set request ($request + 1);
        :local arrayResult [:toarray ($result->"data")];
        :if ([:typeof $arrayResult] = "array") do={
            :if ([:pick $arrayResult 0] = "success") do={
                :set idx ($idx + 1);
                :put ([$format $idx 4] . [$format $dstIp 16] . [$format ($arrayResult->2) 10] . [$format ($arrayResult->1) 25] . [$format ($arrayResult->4) 30]);
            }
        }
    } on-error={
        :put ([$format $dstIp 16] . " - ERROR");
    }
}

#TODO-END