#Version: 7.0
#Fecha: 16-07-2023
#RouterOS: 7.10 y superior.
#Comentario:

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
