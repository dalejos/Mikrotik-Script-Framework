:if ([:len [/system script job find script="script-telegram-routes"]] > 1) do={
    :return 255;
}

:global config;
:global telegramSendMessage;

:local botToken ($config->"telegram"->"botToken");
:local chatID ($config->"telegram"->"chatID");

:local identity [/system identity get name];

:foreach id in=[/ip route find where comment~"MAIN"] do={
	:local route [/ip route get $id];
	:local comment ($route->"comment");
	:local icon "\F0\9F\98\81";
	:set icon "\E2\9C\85";
	:if (!($route->"active")) do={
		:set icon "\F0\9F\98\A1";
		:set icon "\E2\9D\8C";
	}
	:local index [:tonum ("0x" . [:pick $id 1 [:len $id]])];
	:if ([:len ($config->"telegram"->"routes"->"R$index")] = 0) do={
		:local identity [/system identity get name];
		:local message "*Identity*\n\
					   name: *$identity*\n\n\
					   *Informacion de ruta* $icon\n";			
		:foreach k,v in=$route do={
			:if ($k!=".id") do={
				:set message "$message$k: *$v*\n";
			}
		}			
		:local send [$telegramSendMessage $botToken $chatID $message "Markdown"];
		:if ($send) do={
			:set ($config->"telegram"->"routes"->"R$index") ($route->"active");
		}
	} else={
		:if (($config->"telegram"->"routes"->"R$index") != ($route->"active")) do={
            :local identity [/system identity get name];
            :local message "*Identity*\n\
                           name: *$identity*\n\n\
                           *Informacion de ruta* $icon\n";			
			:foreach k,v in=$route do={
				:if ($k!=".id") do={
					:set message "$message$k: *$v*\n";
				}
			}			
			:local send [$telegramSendMessage $botToken $chatID $message "Markdown"];
			:if ($send) do={
				:set ($config->"telegram"->"routes"->"R$index") ($route->"active");
			}
		}
	}
}
