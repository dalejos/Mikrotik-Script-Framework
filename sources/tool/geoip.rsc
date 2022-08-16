#Version: 7.0.
#Fecha: 02-07-2022.
#RouterOS 7.2.3 y superior.
#Comentario: 

#TODO-BEGIN

:global geoIP;
:set geoIP do={

	:local services {\
	"tcp"={\
		"7"="echo";\
		"9"="discard";\
		"11"="systat";\
		"13"="daytime";\
		"17"="qotd";\
		"19"="chargen";\
		"20"="ftp-data";\
		"21"="ftp";\
		"22"="ssh";\
		"23"="telnet";\
		"25"="smtp";\
		"37"="time";\
		"42"="nameserver";\
		"43"="nicname";\
		"53"="domain";\
		"70"="gopher";\
		"79"="finger";\
		"80"="http";\
		"81"="hosts2-ns";\
		"88"="kerberos";\
		"101"="hostname";\
		"102"="iso-tsap";\
		"107"="rtelnet";\
		"109"="pop2";\
		"110"="pop3";\
		"111"="sunrpc";\
		"113"="auth";\
		"117"="uucp-path";\
		"118"="sqlserv";\
		"119"="nntp";\
		"135"="epmap";\
		"137"="netbios-ns";\
		"139"="netbios-ssn";\
		"143"="imap";\
		"150"="sql-net";\
		"156"="sqlsrv";\
		"158"="pcmail-srv";\
		"170"="print-srv";\
		"179"="bgp";\
		"194"="irc";\
		"322"="rtsps";\
		"349"="mftp";\
		"389"="ldap";\
		"443"="https";\
		"445"="microsoft-ds";\
		"464"="kpasswd";\
		"507"="crs";\
		"512"="exec";\
		"513"="login";\
		"514"="cmd";\
		"515"="printer";\
		"520"="efs";\
		"522"="ulp";\
		"526"="tempo";\
		"529"="irc-serv";\
		"530"="courier";\
		"531"="conference";\
		"532"="netnews";\
		"540"="uucp";\
		"543"="klogin";\
		"544"="kshell";\
		"546"="dhcpv6-client";\
		"547"="dhcpv6-server";\
		"548"="afpovertcp";\
		"554"="rtsp";\
		"556"="remotefs";\
		"563"="nntps";\
		"565"="whoami";\
		"568"="ms-shuttle";\
		"569"="ms-rome";\
		"593"="http-rpc-epmap";\
		"612"="hmmp-ind";\
		"613"="hmmp-op";\
		"636"="ldaps";\
		"666"="doom";\
		"691"="msexch-routing";\
		"749"="kerberos-adm";\
		"800"="mdbs_daemon";\
		"989"="ftps-data";\
		"990"="ftps";\
		"992"="telnets";\
		"993"="imaps";\
		"994"="ircs";\
		"995"="pop3s";\
		"1109"="kpop";\
		"1110"="nfsd-status";\
		"1155"="nfa";\
		"1034"="activesync";\
		"1270"="opsmgr";\
		"1433"="ms-sql-s";\
		"1434"="ms-sql-m";\
		"1477"="ms-sna-server";\
		"1478"="ms-sna-base";\
		"1512"="wins";\
		"1524"="ingreslock";\
		"1607"="stt";\
		"1711"="pptconference";\
		"1723"="pptp";\
		"1731"="msiccp";\
		"1745"="remote-winsock";\
		"1755"="ms-streaming";\
		"1801"="msmq";\
		"1863"="msnp";\
		"1900"="ssdp";\
		"1944"="close-combat";\
		"2053"="knetd";\
		"2106"="mzap";\
		"2177"="qwave";\
		"2234"="directplay";\
		"2382"="ms-olap3";\
		"2383"="ms-olap4";\
		"2393"="ms-olap1";\
		"2394"="ms-olap2";\
		"2460"="ms-theater";\
		"2504"="wlbs";\
		"2525"="ms-v-worlds";\
		"2701"="sms-rcinfo";\
		"2702"="sms-xfer";\
		"2703"="sms-chat";\
		"2704"="sms-remctrl";\
		"2725"="msolap-ptp2";\
		"2869"="icslap";\
		"3020"="cifs";\
		"3074"="xbox";\
		"3126"="ms-dotnetster";\
		"3132"="ms-rule-engine";\
		"3268"="msft-gc";\
		"3269"="msft-gc-ssl";\
		"3343"="ms-cluster-net";\
		"3389"="ms-wbt-server";\
		"3535"="ms-la";\
		"3540"="pnrp-port";\
		"3544"="teredo";\
		"3587"="p2pgroup";\
		"3702"="ws-discovery";\
		"3776"="dvcprov-port";\
		"3847"="msfw-control";\
		"3882"="msdts1";\
		"3935"="sdp-portmapper";\
		"4350"="net-device";\
		"4500"="ipsec-msft";\
		"5228"="android-market";\		
		"5355"="llmnr";\
		"5357"="wsd";\
		"5358"="wsd";\
		"5678"="rrac";\
		"5679"="dccm";\
		"5720"="ms-licensing";\
		"6073"="directplay8";\
		"7680"="ms-do";\
		"9535"="man";\
		"9753"="rasadv";\
		"11320"="imip-channels";\
		"47624"="directplaysrvr"\
		};\
	"udp"={\
		"7"="echo";\
		"9"="discard";\
		"11"="systat";\
		"13"="daytime";\
		"17"="qotd";\
		"19"="chargen";\
		"37"="time";\
		"39"="rlp";\
		"42"="nameserver";\
		"53"="domain";\
		"67"="bootps";\
		"68"="bootpc";\
		"69"="tftp";\
		"81"="hosts2-ns";\
		"88"="kerberos";\
		"111"="sunrpc";\
		"123"="ntp";\
		"135"="epmap";\
		"137"="netbios-ns";\
		"138"="netbios-dgm";\
		"161"="snmp";\
		"162"="snmptrap";\
		"213"="ipx";\
		"322"="rtsps";\
		"349"="mftp";\
		"443"="https";\
		"445"="microsoft-ds";\
		"464"="kpasswd";\
		"500"="isakmp";\
		"507"="crs";\
		"512"="biff";\
		"513"="who";\
		"514"="syslog";\
		"517"="talk";\
		"518"="ntalk";\
		"520"="router";\
		"522"="ulp";\
		"525"="timed";\
		"529"="irc-serv";\
		"533"="netwall";\
		"546"="dhcpv6-client";\
		"547"="dhcpv6-server";\
		"548"="afpovertcp";\
		"550"="new-rwho";\
		"554"="rtsp";\
		"560"="rmonitor";\
		"561"="monitor";\
		"563"="nntps";\
		"565"="whoami";\
		"568"="ms-shuttle";\
		"569"="ms-rome";\
		"593"="http-rpc-epmap";\
		"612"="hmmp-ind";\
		"613"="hmmp-op";\
		"666"="doom";\
		"691"="msexch-routing";\
		"749"="kerberos-adm";\
		"750"="kerberos-iv";\
		"800"="mdbs_daemon";\
		"995"="pop3s";\
		"1110"="nfsd-keepalive";\
		"1155"="nfa";\
		"1167"="phone";\
		"1270"="opsmgr";\
		"1433"="ms-sql-s";\
		"1434"="ms-sql-m";\
		"1477"="ms-sna-server";\
		"1478"="ms-sna-base";\
		"1512"="wins";\
		"1607"="stt";\
		"1701"="l2tp";\
		"1711"="pptconference";\
		"1731"="msiccp";\
		"1745"="remote-winsock";\
		"1755"="ms-streaming";\
		"1801"="msmq";\
		"1812"="radius";\
		"1813"="radacct";\
		"1863"="msnp";\
		"1900"="ssdp";\
		"1944"="close-combat";\
		"2049"="nfsd";\
		"2106"="mzap";\
		"2177"="qwave";\
		"2234"="directplay";\
		"2382"="ms-olap3";\
		"2383"="ms-olap4";\
		"2393"="ms-olap1";\
		"2394"="ms-olap2";\
		"2460"="ms-theater";\
		"2504"="wlbs";\
		"2525"="ms-v-worlds";\
		"2701"="sms-rcinfo";\
		"2702"="sms-xfer";\
		"2703"="sms-chat";\
		"2704"="sms-remctrl";\
		"2725"="msolap-ptp2";\
		"2869"="icslap";\
		"3020"="cifs";\
		"3074"="xbox";\
		"3126"="ms-dotnetster";\
		"3132"="ms-rule-engine";\
		"3268"="msft-gc";\
		"3269"="msft-gc-ssl";\
		"3343"="ms-cluster-net";\
		"3389"="ms-wbt-server";\
		"3535"="ms-la";\
		"3540"="pnrp-port";\
		"3544"="teredo";\
		"3587"="p2pgroup";\
		"3702"="ws-discovery";\
		"3776"="dvcprov-port";\
		"3935"="sdp-portmapper";\
		"4350"="net-device";\
		"4500"="ipsec-msft";\
		"5355"="llmnr";\
		"5678"="rrac";\
		"5679"="dccm";\
		"5720"="ms-licensing";\
		"6073"="directplay8";\
		"7680"="ms-do";\
		"9753"="rasadv";\
		"9993"="zerotier";\
		"11320"="imip-channels";\
		"47624"="directplaysrvr"\
		}\
	}

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
	:local src $"src-address";
	:local firewallConnections [/ip firewall connection find where src-address~"$src"];

	/terminal style syntax-noterm;
	:put ("Nro. de conexiones: " . [:len $firewallConnections]);
	:put "";
	:put ([$format "#" 5] . [$format "SRC. ADDRESS" 22] . [$format "DST. ADDRESS" 22] . [$format "PROTO" 7] . [$format "SERVICE" 14] \
	. [$format "COUNTRY" 9] . [$format "COUNTRY NAME" 25] . [$format "AS" 10] . [$format "AS NAME" 30]);
	/terminal style none;

	:foreach id in=$firewallConnections do={
		:local connection [/ip firewall connection get $id];
		:local dstAddress ($connection->"dst-address");
		:local srcAddress ($connection->"src-address");
		:local protocol ($connection->"protocol");
		
		:if (([:len $dstAddress] > 0) and ([:len $srcAddress] > 0)) do={
			:local data;
			:local dnsCache ([]);
			:local dnsData;
			
			:local dstIp $dstAddress;
			:local protocolPort "";
			:local doubleDot [:find $dstIp ":"];
			:if ( $doubleDot > 0) do={ 
				:set protocolPort [:pick $dstIp ($doubleDot+1) [:len $dstIp]];
				:set protocolPort ($services->"$protocol"->"$protocolPort");
				:set dstIp [:pick $dstIp 0 $doubleDot];
				:if ([:len $protocolPort] > 0) do={
					:set protocolPort "> $protocolPort";
				} else={
					:local srcIp $srcAddress;
					:set doubleDot [:find $srcIp ":"];
					:if ( $doubleDot > 0) do={ 
						:set protocolPort [:pick $srcIp ($doubleDot+1) [:len $srcIp]];
						:set protocolPort ($services->"$protocol"->"$protocolPort");
						:if ([:len $protocolPort] > 0) do={
							:set protocolPort "< $protocolPort";
						}
					}
				}
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
			:put ([$format $idx 5] . [$format $srcAddress 22] . [$format $dstAddress 22] . [$format $protocol 7] . [$format $protocolPort 14] \
			. [$format ($data->"countryCode") 9] . [$format ($data->"country") 25] . [$format ($data->"as") 10] . [$format ($data->"asname") 30]);
			:if ([:len $dnsCache] > 0) do={
				:foreach dnsData in=$dnsCache do={
					:put ([$format ("     type: " . ($dnsData->"type")) 27] . [$format ("name: " . ($dnsData->"name")) 50]);
				}
				:put "";
			}
		}
	}

}
#TODO-END