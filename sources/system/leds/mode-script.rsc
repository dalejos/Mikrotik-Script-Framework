#Version: 7.0
#Fecha: 16-07-2023
#RouterOS: 7.10 y superior.
#Comentario:

:local wifiName "EAP";
:local signalRange "-75..0";
:local buttonName "modeButton";

:global button;
:if ([:typeof $button] = "array") do={
	:if ([:typeof ($button->$buttonName)] = "array") do={
	
		:local wifiRegexp "$wifiName\$";
		:local reg [/interface/wifiwave2/registration-table/find where ssid~$wifiRegexp];
		
		/interface/wifiwave2/access-list/set [find where ssid-regexp~$wifiRegexp and !mac-address] disabled=yes;
		
		:while (($button->$buttonName->"active") && (!($button->$buttonName->"completed"))) do={

			/delay delay-time=1s

			:local regTemp [/interface/wifiwave2/registration-table/print detail as-value where ssid~$wifiRegexp];

			:foreach r in=$regTemp do={
				:if (!([:find $reg ($r->".id")] >= 0)) do={
					:local id [/interface/wifiwave2/access-list/find where mac-address=($r->"mac-address") and ssid-regexp=$wifiName and action=accept];
					:if ([:len $id] <= 0) do={
						/interface/wifiwave2/access-list/add mac-address=($r->"mac-address") ssid-regexp=$wifiName signal-range=$signalRange action=accept place-before=0;
						:set ($button->$buttonName->"completed") true;
					}
				}
			}
		}
		
		/interface/wifiwave2/access-list/set [find where ssid-regexp~$wifiRegexp and !mac-address] disabled=no;		
	}
}
