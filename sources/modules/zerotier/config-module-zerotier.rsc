{

:global config;
:if ([:typeof $config] != "array") do={
    :set $config [:toarray ""];
}

:local version "v1";
:local token "";

:local authorization ("Authorization: token " . $token);;
:local url "https://api.zerotier.com/api/$version";

:local zerotier {"url"=$url; "authorization"=$authorization};

:set ($config->"zerotier") $zerotier;

}