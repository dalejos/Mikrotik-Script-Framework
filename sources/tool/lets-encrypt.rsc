#Version: 7.0.
#Fecha: 17-07-2024.
#RouterOS 7.14 y superior.
#Comentario: 

#TODO-BEGIN

{
	:local certificateDomain "";
	
	:local filterInputFirewall true;
	:local firewallComment "http-lets-encrypt-script";

	:if ([:len $certificateDomain] = 0) do={
		:local cloud [ip/cloud/get];
		:set certificateDomain ($cloud->"dns-name");
	}

	:put "";
	:if ([:len $certificateDomain] > 0) do={
		:put "Iniciando proceso de certificado SSL para el dominio: $certificateDomain";
				
		:local filterRuleId;
		:if ($filterInputFirewall) do={
			:set filterRuleId [/ip/firewall/filter/find where comment=$firewallComment];
			:if ([:len $filterRuleId] > 0) do={
				:put "";
				:put "Removiendo filter firewall ejecucion previa.";
				/ip/firewall/filter/remove $filterRuleId;
			}
			:put "";
			:put "Agregando filter firewall.";
			:set filterRuleId [/ip/firewall/filter/add chain=input protocol=tcp dst-port=80,443 action=accept comment=$firewallComment place-before=0];
		}
		
		:if ([:len $filterRuleId] > 0) do={
			:local httpService [/ip/service/get [find where name="www"]];
			:local httpsService [/ip/service/get [find where name="www-ssl"]];
			/ip/service/set ($httpService->".id") disabled=no;
			/ip/service/set ($httpsService->".id") disabled=no;
			
			:put "";
			:put "Generando certificado...";
			
			:local certificateData [/certificate/enable-ssl-certificate dns-name=$certificateDomain as-value];
			
			:put "";
			:put ("Resultado: " . ($certificateData->"progress"));
			
			:if ($httpService->"disabled") do={
				/ip/service/set ($httpService->".id") disabled=yes;
			}			
			
			:put "";
			:put "Removiendo filter firewall.";
			/ip/firewall/filter/remove $filterRuleId;
		}
	}
}