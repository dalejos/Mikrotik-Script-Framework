
:local scritpName "module-zerotier";

:local requireModules {};

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

:global zerotierNetwork;
:set zerotierNetwork do={
	:global config;

	:local zerotier ($config->"zerotier");
	:local endPoint "/network";
		
	:local result [/tool/fetch url=($zerotier->"url" . $endPoint) http-header-field=($zerotier->"authorization") output=user as-value];
	
	:if (($result->"status") = "finished") do={
		:set ($result->"data") [:deserialize from=json value=($result->"data")];
	}

    :return $result;
}

:global zerotierNetworkListMembers;
:set zerotierNetworkListMembers do={
	:global config;

	:local zerotier ($config->"zerotier");
	:local networkID $1;
	:local endPoint "/network/$networkID/member";
		
	:local result [/tool/fetch url=($zerotier->"url" . $endPoint) http-header-field=($zerotier->"authorization") output=user as-value];

	:if (($result->"status") = "finished") do={
		:set ($result->"data") [:deserialize from=json value=($result->"data")];
	}

    :return $result;
}






