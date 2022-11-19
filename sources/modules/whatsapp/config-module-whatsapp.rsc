:global config;
:if ([:typeof $config] != "array") do={
    :set $config [:toarray ""];
}

:local version "v15.0";
:local identificador "";
:local url "https://graph.facebook.com/$version/$identificador/messages";
:local accessToken "";

:local whatsapp {"url"=$url; "version"=$version; "identificador"=$identificador; "accessToken"=$accessToken};

:set ($config->"whatsapp") $whatsapp;