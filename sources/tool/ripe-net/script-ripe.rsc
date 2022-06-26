:if ([:len [/system script job find script="script-ripe"]] > 1) do={
    :return 255;
}

:global dataRipe;
:global JSONLoads;
:local jsonResponse;

:local list {
	{"name"="FACEBOOK"; "resources"={"AS63293";"AS54115";"AS32934"}}
};

:foreach item in=$list do={
	:put ($item->"name");
	
	:foreach resource in=($item->"resources") do={
		:put $resource;
		:set jsonResponse [$JSONLoads [$dataRipe "ris-prefixes" ("resource=$resource&list_prefixes=true")]];
		:foreach prefix in=($jsonResponse->"data"->"prefixes"->"v4"->"originating") do={
			do {
				/ip firewall address-list add list=($item->"name") address=$prefix timeout=60m;
			} on-error={
				:put "Error al agregar $prefix";
			}
		}
	}	
}

:global jsonResponse [$JSONLoads [$dataRipe "ris-prefixes" "resource=AS2906&list_prefixes=true"]];

:foreach prefix in=($jsonResponse->"data"->"prefixes"->"v4"->"originating") do={
	/ip firewall address-list add list=NETFLIX address=$prefix timeout=60m;
}