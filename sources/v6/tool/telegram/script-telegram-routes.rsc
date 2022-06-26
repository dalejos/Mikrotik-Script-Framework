:if ([:len [/system script job find script="script-telegram-routes"]] > 1) do={
    :return 255;
}

:global config;
:global telegramSendMessage;

:local botToken ($config->"telegram"->"botToken");
:local chatID ($config->"telegram"->"chatID");

:local identity [/system identity get name];

:local list ($config->"telegram"->"routes"->"list");
:local messages ($config->"telegram"->"routes"->"messages");

:foreach id in=[/ip route find where comment~"MAIN"] do={
	:local route [/ip route get $id];
	:local icon "\F0\9F\98\81";
	:set icon "\E2\9C\85";
	:if (!($route->"active")) do={
		:set icon "\F0\9F\98\A1";
		:set icon "\E2\9D\8C";
	}
	:local index [:tonum ("0x" . [:pick $id 1 [:len $id]])];
    

    
	:if ([:len ($list->"id-$index")] = 0) do={
		:local identity [/system identity get name];
		:local message "*Identity*\n\
					   name: *$identity*\n\n\
					   *Informacion de ruta* $icon\n";			
		:foreach k,v in=$route do={
			:if ($k!=".id") do={
				:set message "$message$k: *$v*\n";
			}
		}			
        :set ($list->"id-$index") ($route->"active");
        :local length ([:len $messages] + 1);
        :set ($messages->"id-$length") $message;
        
	} else={
		:if (($list->"id-$index") != ($route->"active")) do={
            :local identity [/system identity get name];
            :local message "*Identity*\n\
                           name: *$identity*\n\n\
                           *Informacion de ruta* $icon\n";			
			:foreach k,v in=$route do={
				:if ($k!=".id") do={
					:set message "$message$k: *$v*\n";
				}
			}
            :set ($list->"id-$index") ($route->"active");
            :local length ([:len $messages] + 1);
            :set ($messages->"id-$length") $message;
		}
	}
}
:set ($config->"telegram"->"routes"->"list") $list;
:set ($config->"telegram"->"routes"->"messages") $messages;

:foreach id,message in=($config->"telegram"->"routes"->"messages") do={
    :local send [$telegramSendMessage $botToken $chatID $message "Markdown"];    
    :if ($send) do={
        :set ($config->"telegram"->"routes"->"messages"->"$id");
    }
}
