#Version: 7.0.
#Fecha: 02-07-2022.
#RouterOS 7.19.0 y superior.
#Comentario: 

#TODO-BEGIN

:global geoTracert;
:set geoTracert do={

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
	:local timeStamp [:timestamp];

	:local ipAddress;

	:local hostName "";
	:local reverseHostName "";
	:local tracertCount 3;
	:local maxHops 30;
	:local isIPv6 false;
	
	:if ([:typeof [:toip $1]] = "ip") do={
		:set ipAddress $1;
		do {
			:set reverseHostName [:resolve $ipAddress];
		} on-error={
			:set reverseHostName $ipAddress;
		}
	} else={
		:if ([:typeof [:toip6 $1]] = "ip6") do={
			:set isIPv6 true;
			:set ipAddress $1;
			do {
				:set hostName [:resolve $ipAddress];
			} on-error={
				:set hostName $ipAddress;
			}
		} else={
			:set hostName $1;
			:set ipAddress [:resolve $hostName];
			do {
				:set reverseHostName [:resolve $ipAddress];
			} on-error={
				:set reverseHostName $ipAddress;
			}		
			
		}
	}
	
	:if ([:tonum $2] > 0) do={
		:set tracertCount [:tonum $2];
	}

	:if ([:tonum $3] > 0) do={
		:set maxHops [:tonum $3];
	}

	:local tracertResult [/tool/traceroute $ipAddress count=$tracertCount max-hops=$maxHops as-value];
	
	#Se agrega para corregir devolucion de datos de traceroute
	:if ([:len ($tracertResult->"address")] > 0) do={
		:set $tracertResult ({$tracertResult});
	}

	/terminal style syntax-noterm;
	
	:local hosts "";
	:if (([:len $hostName] > 0) and ([:len $reverseHostName] > 0)) do={
		:set hosts "$hostName, $reverseHostName";
	} else={
		:set hosts "$hostName$reverseHostName";
	}
	:put "";
	:put ("Nro. de saltos a $ipAddress ($hosts): " . [:len $tracertResult]);
	:put "";
	:put ([$format "HOP" 5] . [$format "HOST" 40] . [$format "LOSS" 6] . [$format "SENT" 5] . [$format "LAST" 9] . [$format "AVG" 6] \
	. [$format "BEST" 6] . [$format "WORST" 7] . [$format "STD DEV" 9] \
	. [$format "COUNTRY" 9] . [$format "COUNTRY NAME" 25] . [$format "AS" 10] . [$format "AS NAME" 30]);
	/terminal style none;



	:foreach jump in=$tracertResult do={
		:local dstIp [:tostr ($jump->"address")];
		:set ($jump->"loss") ((($jump->"loss") / 10) . "%");
		:if (($jump->"last") = 4294967295) do={
			:set ($jump->"last") "timeout";
		} else={
			:set ($jump->"last") ((($jump->"last") / 10) . "ms");
			:set ($jump->"avg") (($jump->"avg") / 10);
			:set ($jump->"best") (($jump->"best") / 10);
			:set ($jump->"worst") (($jump->"worst") / 10);
			:set ($jump->"std-dev") (($jump->"std-dev") / 10);
		}
		:set idx ($idx + 1);		
		:if ([:len $dstIp] > 0) do={
			:local data;
			:local dnsCache ([]);
			:local dnsData;
			
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
			
			
				:local lUrl "http://ip-api.com/json/$dstIp?fields=status,message,country,countryCode,region,regionName,city,zip,lat,lon,timezone,isp,org,as,asname,reverse,query";
				:local result;
				
				
				do {
					:local isPrivate false;
					:local isReserved false;
					
					:if ($isIPv6) do={
						:set isPrivate false;
						:set isReserved false;
					} else={
						:set isPrivate  ((10.0.0.0 = ($dstIp&255.0.0.0)) or (172.16.0.0 = ($dstIp&255.240.0.0)) or  (192.168.0.0 = ($dstIp&255.255.0.0)));
						:set isReserved ((0.0.0.0 = ($dstIp&255.0.0.0)) or (127.0.0.0 = ($dstIp&255.0.0.0)) or (169.254.0.0 = ($dstIp&255.255.0.0)) \
						or (224.0.0.0 = ($dstIp&240.0.0.0)) or (240.0.0.0 = ($dstIp&240.0.0.0)));
					}
					
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
							:local timeToDelay ([:timestamp] - $timeStamp);
							:if ($timeToDelay < 65s) do={
								:delay (65s - $timeToDelay);
							}
							:set timeStamp [:timestamp];
						}
						
						:local arrayResult [:deserialize ($result->"data") from=json];
						
						:if ([:typeof $arrayResult] = "array") do={
							:if (($arrayResult->"status") = "success") do={
								:local as (($arrayResult->"as") . " ");
								:set as [:pick $as 0 [:find $as " "]];
								:local asName ($arrayResult->"asname");
								:if ([:len $asName] <= 0) do={
									:set asName ($arrayResult->"isp");
									:if ([:len $asName] <= 0) do={
										:set asName ($arrayResult->"org");
									}
								}
								:set data {"country"=($arrayResult->"country"); "countryCode"=($arrayResult->"countryCode"); "as"=$as; "asname"=$asName; "dnsCache"=($dnsCache)};
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

			:put ([$format $idx 5] . [$format $dstIp 40] . [$format ($jump->"loss") 6]  . [$format ($jump->"sent") 5] . [$format ($jump->"last") 9] . [$format ($jump->"avg") 6] \
			. [$format ($jump->"best") 6] . [$format ($jump->"worst") 7] . [$format ($jump->"std-dev") 9] \
			. [$format ($data->"countryCode") 9] . [$format ($data->"country") 25] . [$format ($data->"as") 10] . [$format ($data->"asname") 30]);
	#        :if ([:len $dnsCache] > 0) do={
	#            :foreach dnsData in=$dnsCache do={
	#                :put ([$format ("     type: " . ($dnsData->"type")) 27] . [$format ("name: " . ($dnsData->"name")) 50]);
	#            }
	#            :put "";
	#        }
		} else={
			:put ([$format $idx 5] . [$format $dstIp 40] . [$format ($jump->"loss") 6]  . [$format ($jump->"sent") 5] . [$format ($jump->"last") 9] . [$format ($jump->"avg") 6] \
			. [$format ($jump->"best") 6] . [$format ($jump->"worst") 7] . [$format ($jump->"std-dev") 9]);
		}
	}
}
#TODO-END