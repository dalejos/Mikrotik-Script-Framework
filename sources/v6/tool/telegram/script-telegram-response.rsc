:if ([:len [/system script job find script="script-telegram-active-users"]] > 1) do={
    :return 255;
}

:global config;
:global telegramSendMessage;
:global telegramGetUpdates;
:global JSONLoads;

:local botToken ($config->"telegram"->"botToken");
:local chatID ($config->"telegram"->"chatID");

:global jsonResponse [$JSONLoads [$telegramGetUpdates $botToken (($config->"telegram"->"updateId") + 1) 1]];

:if (($jsonResponse->"ok") = true) do={
    :if ([:len ($jsonResponse->"result")] = 1) do={
        :local update (($jsonResponse->"result"->0));
        :local message (($jsonResponse->"result"->0->"message"));
        :set ($config->"telegram"->"updateId") ($update->"update_id");
        
        :if (($message->"text") = "/getrbinfo") do={
            :local identity [/system identity get name];
            :local response "*Identity*\n\
                            name: *$identity*\n\n\
                            *Routerboard*\n";
            :foreach k,v in=[/system routerboard get] do={
                :set response "$response$k: *$v*\n";
            }
            :local send [$telegramSendMessage $botToken $chatID $response "Markdown" ($message->"message_id")];    
        }
        
        :if (($message->"text") = "/getwirelessinfo") do={
            :local response "";
            :foreach id in=[/interface wireless find] do={
                :local wl [/interface wireless get $id];
                :set response "*Interface*\n\
                                name: *$($wl->"name")*\n\n\
                                *Monitor*\n";
                :local wlMonitor [/interface wireless monitor $id once as-value];
                :foreach k,v in=$wlMonitor do={
                    :if ($k!=".id") do={
                        :set response "$response$k: *$v*\n";
                    }
                }
            }
            :local send [$telegramSendMessage $botToken $chatID $response "Markdown" ($message->"message_id")];    
        }
    }
}