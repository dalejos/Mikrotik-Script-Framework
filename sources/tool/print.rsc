#Version: 7.0.
#Fecha: 02-07-2022.
#RouterOS 7.2.3 y superior.
#Comentario: 

#TODO-BEGIN
:global printIPv4Routes;
:set printIPv4Routes do={

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
	
	:local routeList [/ip/route/print proplist=dst-address,gateway,immediate-gw,routing-table,inactive,distance,disabled,active,ecmp,connect,blackhole,dhcp,dynamic,ospf,bgp,vpn,static,hw-offloaded,vrf-interface as-value];
	
	/terminal style syntax-noterm;
	:put "";
	:put ([$format "STATUS" 6] . [$format "ROUTE" 20] . [$format "DST" 5] . [$format "GATEWAY" 35] . [$format "IMMEDIATE GATEWAY" 35]);
	/terminal style none;
	
	:local st;
	:foreach route in=$routeList do={
		:set st "";
		:if ($route->"disabled") do={
			:set st ($st . "X");
		}
		:if ($route->"active") do={
			:set st ($st . "A");
		}
		:if ($route->"static") do={
			:set st ($st . "S");
		}
		:if ($route->"dynamic") do={
			:set st ($st . "D");
			:set st "$stD";
		}
		:if ($route->"connect") do={
			:set st ($st . "C");
		}
		:if ($route->"inactive") do={
			:set st ($st . "I");
		}
		:if ($route->"blackhole") do={
			:set st ($st . "B");
		}
		:if ($route->"dhcp") do={
			:set st ($st . "d");
		}
		:if ($route->"ospf") do={
			:set st ($st . "o");
		}
		:if ($route->"bgp") do={
			:set st ($st . "b");
		}
		:if ($route->"vpn") do={
			:set st ($st . "v");
		}
		:if ($route->"hw-offloaded") do={
			:set st ($st . "H");
		}
		:if ($route->"ecmp") do={
			:set st ($st . "+");
		}
		:put ([$format $st 6] . [$format ($route->"dst-address") 20] . [$format ($route->"distance") 5] . [$format ($route->"gateway") 35] . [$format ($route->"immediate-gw") 35]);
	}

}
