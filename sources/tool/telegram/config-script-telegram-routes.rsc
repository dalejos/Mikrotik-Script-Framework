:global config;
:if ([:typeof $config] != "array") do={
    :set $config [:toarray ""];
}

:if ([:typeof ($config->"telegram")] = "array" ) do={
    :set ($config->"telegram"->"routes") [:toarray ""];
}