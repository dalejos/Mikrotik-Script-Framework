#Version: 7.5.
#Fecha: 17-11-2022.
#RouterOS 7.2.3 y superior.
#Comentario: 

#TODO-BEGIN

{
	:local segmentoIp "192.168.50.0/24";
	:local passwordRouter "";
	:local updateRouter true;
	
	:local dhcpLeases [/ip/dhcp-server/lease/find where address in $segmentoIp];
	:foreach id in=$dhcpLeases do={
		:local lease [/ip/dhcp-server/lease/get $id];
		:local addRouter true;
		:if ([:len ($lease->"host-name")] > 0) do={
			:local routerId [/user-manager/router/find where address=($lease->"address")];
			
			:if ([:len $routerId] > 0) do={
				:set addRouter $updateRouter;
				:if ($updateRouter) do={
					:put ("Eliminando router " . ($lease->"host-name"));
					/user-manager/router/remove $routerId;
				}
			}
			
			:if ($addRouter) do={
				:put ("Agregando router " . ($lease->"host-name"));
				/user-manager/router/add address=($lease->"address") name=($lease->"host-name") shared-secret=$passwordRouter;
			}
			
		}
	}
}

#TODO-END