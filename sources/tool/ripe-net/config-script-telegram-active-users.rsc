:global config;
:if ([:typeof $config] != "array") do={
    :set $config [:toarray ""];
}

:if ([:typeof ($config->"telegram")] = "array" ) do={
    :local activeUsers {"lastUser"=0; "messages"=[:toarray ""]};
    :set ($config->"telegram"->"activeUsers") $activeUsers;
}