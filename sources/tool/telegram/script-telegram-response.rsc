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
            :local response "*Identity*%0A\
                            name: *$identity*%0A%0A\
                            *Routerboard*%0A";
            :foreach k,v in=[/system routerboard get] do={
                :set response "$response$k: *$v*%0A";
            }
            :local send [$telegramSendMessage $botToken $chatID $response "Markdown" ($message->"message_id")];    
        }
        
    }
}