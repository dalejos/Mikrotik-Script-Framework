#Version: 7.0
#Fecha: 26-06-2022
#RouterOS: 7.10 y superior.
#Comentario:

:local buttonName "modeButton";
:local seconds 60;
:local ledScript "mode-led";
:local ledName "led5";
:local runScript "mode-script";

:global button;
:if ([:typeof $button] != "array") do={
    :set $button [:toarray ""];
}

:if ([:typeof ($button->$buttonName)] != "array") do={
	:set ($button->$buttonName) {"active"=false; "ledScript"=$ledScript; "ledsName"=$ledName; "seconds"=$seconds; "countDown"=0; "runScript"=$runScript; "completed"=false};
}

:if (!($button->$buttonName->"active")) do={
	/log/info "MODE BUTTON: Iniciando tarea.";
	
	:set ($button->$buttonName->"active") true;
	
	:local scriptId [/system/script/find where name=($button->$buttonName->"ledScript")];
	:local scriptSource [/system/script/get $scriptId source];
	/execute script=$scriptSource;
	
	:set scriptId [/system/script/find where name=($button->$buttonName->"runScript")];
	:set scriptSource [/system/script/get $scriptId source];
	/execute script=$scriptSource;

	/log/info "MODE BUTTON: Tarea iniciada.";

	:set ($button->$buttonName->"countDown") ($button->$buttonName->"seconds");
	
	:while (($button->$buttonName->"active") && (!($button->$buttonName->"completed")) && (($button->$buttonName->"countDown") > 0)) do={
		/delay delay-time=1;
		:set ($button->$buttonName->"countDown") (($button->$buttonName->"countDown") - 1);
	}
	
	:set ($button->$buttonName->"active") false;
	
	/log/info "MODE BUTTON: Tarea finalizada.";
	
} else={
	:set ($button->$buttonName->"active") false;
}

################################################

:local buttonName "modeButton";

:global button;
:if ([:typeof $button] = "array") do={
	:if ([:typeof ($button->$buttonName)] = "array") do={

		:local ledsName ($button->$buttonName->"ledsName");
		:local ledId [/system/leds/find where leds=$ledsName];
		
		:if ([:len $ledId] > 0) do={
			:local ledDisabled [/system/leds/get $ledId disabled];
			:local ledType "off";
			
			/system/leds/set $ledId disabled=yes;
			/system/leds/add type=$ledType leds=$ledsName;

			:local ledIdTemp [/system/leds/find where leds=$ledsName and !default];
			
			:if ([:len $ledIdTemp] > 0) do={
				:while (($button->$buttonName->"active")) do={
					/delay delay-time=0.5;
					:if ($ledType = "off") do={
						:set ledType "on";
					} else={
						:set ledType "off";				
					}
					/system/leds/set $ledIdTemp type=$ledType;
				}
			}
			/system/leds/remove $ledIdTemp;
			/system/leds/set $ledId disabled=$ledDisabled;

		}
	}
}

################################################

:local buttonName "modeButton";

:global button;
:if ([:typeof $button] = "array") do={
	:if ([:typeof ($button->$buttonName)] = "array") do={
		:while (($button->$buttonName->"active") && (!($button->$buttonName->"completed"))) do={
			/delay delay-time=1;
			/log/info "MODE SCRIPT.";
		}
	}
}

################################################

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

################################################






:local wifiName "EAP";
:local signalRange "-75..0";

:local wifiRegexp "$wifiName\$";
:local reg [/interface/wifiwave2/registration-table/find where ssid~$wifiRegexp];

/interface/wifiwave2/access-list/set [find where ssid-regexp~$wifiRegexp and !mac-address] disabled=yes;

/delay delay-time=10s

:local regTemp [/interface/wifiwave2/registration-table/print detail as-value where ssid~$wifiRegexp];

:foreach r in=$regTemp do={
	:if (!([:find $reg ($r->".id")] >= 0)) do={
		:local id [/interface/wifiwave2/access-list/find where mac-address=($r->"mac-address") and ssid-regexp=$wifiName and action=accept];
		:if ([:len $id] <= 0) do={
			/interface/wifiwave2/access-list/add mac-address=($r->"mac-address") ssid-regexp=$wifiName signal-range=$signalRange action=accept place-before=0;
		}
	}
}

/interface/wifiwave2/access-list/set [find where ssid-regexp~$wifiRegexp and !mac-address] disabled=no;




































