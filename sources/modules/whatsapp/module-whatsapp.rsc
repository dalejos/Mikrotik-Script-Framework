
:local scritpName "module-whatsapp";

:local requireModules {"module-json"={"version"=1}};

:if ([:len $requireModules] > 0) do={
	:global modules;
	:local quit false;
	:foreach k,v in=$requireModules do={
		:if (!any ($modules->$k)) do={
			:put "$scritpName requiere $k";
			:set quit true;
		}
	}
	:if ($quit) do={
		:return 0;
	}
}

:global whatsappSendMessage;
:set whatsappSendMessage do={
	:global config;

	:local whatsapp ($config->"whatsapp");
	:local authorization ("Authorization: Bearer " . $whatsapp->"accessToken");
	:local contentType "Content-Type: application/json";
	:local data $1
		
	:local result [/tool/fetch url=($whatsapp->"url") http-method=post http-header-field="$authorization,$contentType" http-data=$data output=user as-value];

    :return $result;
}










