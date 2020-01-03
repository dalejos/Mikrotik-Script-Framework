#Version: 3.0 alpha.
#Fecha: 22-12-2019.
#RouterOS 6.43 y superior.
#Comentario: Se introduce el calculo del delay para el API, 45 consultas por minuto.

#TODO-BEGIN

:local getCurrentTimestamp;
:local getCurrentTimestamp do={
    :local date [/system clock get date];
    :local months ({"jan"=1;"feb"=2;"mar"=3;"apr"=4;"may"=5;"jun"=6;"jul"=7;"aug"=8;"sep"=9;"oct"=10;"nov"=11;"dec"=12});
    :local daysForMonths ({31;28;31;30;31;30;31;31;30;31;30;31});
    
    :local day [:tonum [:pick $date 4 6]];
    :local month ($months->[:pick $date 0 3]);
    :local year [:tonum [:pick $date 7 11]];
    
    :local leapDays (($year - 1968) / 4);
    
    :if ((($leapDays * 4) + 1968) = $year) do={
        :set leapDays ($leapDays - 1);
        :set ($daysForMonths->1) 29;
    }
    
    :local days ($day - 1);
    
    :if (($month - 1) > 0) do={
        :for index from=0 to=($month - 2) do={
            :set days ($days + ($daysForMonths->($index)));
        }
    }
        
    :local daysForYear 365;
    :local secondsForDay 86400;
    :local gmtOffset [/system clock get gmt-offset];
    
    :local now [/system clock get time];
    :local hour [:tonum [:pick $now 0 2]];
    :local minutes [:tonum [:pick $now 3 5]];
    :local seconds [:tonum [:pick $now 6 8]];

    :local timestamp ((((($year - 1970) * $daysForYear) + $leapDays + $days) * $secondsForDay) + ($hour * 3600) + ($minutes * 60) + seconds);
    
    :if ($gmtOffset <= $secondsForDay) do={
        :set timestamp ($timestamp - $gmtOffset);
    } else={
        :set timestamp ($timestamp + (-$gmtOffset&0x00000000FFFFFFFF));
    }
    
    :return $timestamp;    
}


:local format;
:local format do={
    :local src $1;
    :local length $2;
    :local lengthSrc [:len $src];
    
    :if ($lengthSrc < ($length)) do={
        :for index from=$lengthSrc to=($length - 1) do={
            :set src ($src . " ");
        }
    } else={
        :set src ([:pick $src 0 ($length - 1)] . " ");
    }
    :return $src;
}

:local dstAddressQueryList ([]);
:local dstAddressQueryResult ([]);
:local idx 0;
:local request 0;
:local timeStamp [$getCurrentTimestamp];
:local firewallConnections [/ip firewall address-list find list="lure_input_blacklist"];

:put "";
:put ("Nro. de conexiones: " . [:len $firewallConnections]);
:put "";
:put ([$format "#" 5] . [$format "SRC. ADDRESS" 22] . [$format "DST. ADDRESS" 22] . [$format "PROTO" 7] \
. [$format "COUNTRY" 9] . [$format "COUNTRY NAME" 25] . [$format "AS" 10] . [$format "AS NAME" 30]);

:foreach id in=$firewallConnections do={
    :local connection [/ip firewall address-list get $id];
    :local dstAddress ($connection->"address");
    :local srcAddress ($connection->"address");
    :local protocol "";
    
    :if (([:len $dstAddress] > 0) and ([:len $srcAddress] > 0)) do={
        :local data;
        :local dnsCache ([]);
        :local dnsData;
        
        :local dstIp $dstAddress;
        :local doubleDot [:find $dstIp ":"];
        :if ( $doubleDot > 0) do={ 
            :set dstIp [:pick $dstIp 0 $doubleDot];
        }
        
        :local indexFind [:find $dstAddressQueryList $dstIp];
        :if (!($indexFind >=0)) do={
        
            
            :foreach idDns in=[/ip dns cache all find data=$dstIp] do={
                :set dnsData [/ip dns cache all get $idDns];
                :set dnsCache ($dnsCache, {$dnsData});
                
                :foreach oIdDns in=[/ip dns cache all find data=($dnsData->"name")] do={
                    :set dnsData [/ip dns cache all get $oIdDns];
                    :set dnsCache ($dnsCache, {$dnsData});
                }
            }
        
        
            :local lUrl "http://ip-api.com/csv/$dstIp?fields=status,message,country,countryCode,as,asname,query";
            :local result;
            
            
            do {
                :local isPrivate  ((10.0.0.0 = ($dstIp&255.0.0.0)) or (172.16.0.0 = ($dstIp&255.240.0.0)) or  (192.168.0.0 = ($dstIp&255.255.0.0)));
                :local isReserved ((0.0.0.0 = ($dstIp&255.0.0.0)) or (127.0.0.0 = ($dstIp&255.0.0.0)) or (169.254.0.0 = ($dstIp&255.255.0.0)) \
                or (224.0.0.0 = ($dstIp&240.0.0.0)) or (240.0.0.0 = ($dstIp&240.0.0.0)));
                :if ($isPrivate or $isReserved) do={
                    :if ($isPrivate) do={
                        :set data {"country"=""; "countryCode"="PRIVATE"; "as"=""; "asname"=""; "dnsCache"=($dnsCache)};
                    } else={
                        :set data {"country"=""; "countryCode"="RESERVED"; "as"=""; "asname"=""; "dnsCache"=($dnsCache)};
                    }
                } else={
                    :set result [/tool fetch url=$lUrl mode=http as-value output=user];
                    :set request ($request + 1);
                    :if ($request >= 45) do={
                        :set request 0;
                        :local timeToDelay ([$getCurrentTimestamp] - $timeStamp);
                        :if ($timeToDelay < 65) do={
                            :delay (65 - $timeToDelay);
                        }
                        :set timeStamp [$getCurrentTimestamp];
                    }
                    
                    :local arrayResult [:toarray ($result->"data")];
                    
                    :if ([:typeof $arrayResult] = "array") do={
                        :if ([:pick $arrayResult 0] = "success") do={
                            :local as (($arrayResult->3) . " ");
                            :set as [:pick $as 0 [:find $as " "]];
                            :set data {"country"=($arrayResult->1); "countryCode"=($arrayResult->2); "as"=$as; "asname"=($arrayResult->4); "dnsCache"=($dnsCache)};
                        }
                    }
                }
                :set dstAddressQueryList ($dstAddressQueryList, $dstIp);
                :set dstAddressQueryResult ($dstAddressQueryResult, {$data});
            } on-error={
                :put ([$format $dstIp 16] . " - ERROR");
            }
        } else={
            :set data ($dstAddressQueryResult->$indexFind);
            :set dnsCache ($data->"dnsCache");
        }

        :set idx ($idx + 1);
        :put ([$format $idx 5] . [$format $srcAddress 22] . [$format $dstAddress 22] . [$format $protocol 7] \
        . [$format ($data->"countryCode") 9] . [$format ($data->"country") 25] . [$format ($data->"as") 10] . [$format ($data->"asname") 30]);
        :if ([:len $dnsCache] > 0) do={
            :foreach dnsData in=$dnsCache do={
                :put ([$format ("     type: " . ($dnsData->"type")) 27] . [$format ("name: " . ($dnsData->"name")) 50]);
            }
            :put "";
        }
    }
}

#TODO-END