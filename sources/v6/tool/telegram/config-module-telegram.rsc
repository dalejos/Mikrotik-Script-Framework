:global config;
:if ([:typeof $config] != "array") do={
    :set $config [:toarray ""];
}

:local telegram {"botToken"=""; "chatID"=""; "updateId"=0};

:set ($config->"telegram") $telegram;