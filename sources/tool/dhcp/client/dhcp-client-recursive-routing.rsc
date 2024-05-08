{
	:local ispNumber 1;
	:local routingTable "to_wan1";
	:local recursiveGateways ("4.4.4.4", "5.5.5.5");
	:local backupGateways ("9.9.9.9", "208.67.220.220");

	:local maxRecursiveGateways 2;
	:local autoRemove true;
	:local forceRemove false;
	:local routingDisabled "yes";

	:local routingGateway $"gateway-address";
	:local routingComment "$routingTable";
	:local routingDistance ($ispNumber * $maxRecursiveGateways);
	
	:if ($maxRecursiveGateways > 1) do={
		:set routingDistance ($routingDistance - 1);
	}
		
	:if ($bound = 1) do={
		:if ($autoRemove) do={
			:if (([/system/resource/get uptime] < "00:05:00")) do={
				:set forceRemove true;
			}
		}
		
		:if ($forceRemove) do={
			#REMOVER RUTAS
			
			/ip/route/remove [find where comment~$routingComment];
		}
		:local count [/ip/route/print count-only where comment~$routingComment];
		:if ($count = 0) do={
			#CREAR RUTAS
			
			:local recursiveGatewaysDistance 1;
			:foreach recursiveGateway in=$recursiveGateways do={
				/ip/route/add disabled=$routingDisabled dst-address="$recursiveGateway/32" gateway=$routingGateway scope=10 target-scope=10 distance=1 comment="$routingComment - $recursiveGateway/32 RECURSIVE ROUTE - main";
				/ip/route/add disabled=$routingDisabled dst-address="0.0.0.0/0" gateway=$recursiveGateway scope=30 target-scope=20 distance=$routingDistance check-gateway=ping comment="$routingComment - DEFAULT ROUTE - main";
				/ip/route/add disabled=$routingDisabled dst-address="0.0.0.0/0" gateway=$recursiveGateway scope=30 target-scope=20 distance=$recursiveGatewaysDistance check-gateway=ping routing-table=$routingTable comment="$routingComment - DEFAULT RECURSIVE ROUTE - $routingTable";
				:set routingDistance ($routingDistance + 1);
				:set recursiveGatewaysDistance ($recursiveGatewaysDistance + 1);
			}
			:foreach recursiveGateway in=$backupGateways do={
				/ip/route/add disabled=$routingDisabled dst-address="0.0.0.0/0" gateway=$recursiveGateway scope=30 target-scope=20 distance=$recursiveGatewaysDistance check-gateway=ping routing-table=$routingTable comment="$routingComment - DEFAULT BACKUP RECURSIVE ROUTE - $routingTable";
				:set routingDistance ($routingDistance + 1);
				:set recursiveGatewaysDistance ($recursiveGatewaysDistance + 1);
			}
		} else={
			#ACTUALIZAR RUTAS

			:foreach recursiveGateway in=$recursiveGateways do={
				:local id [/ip/route/find where dst-address="$recursiveGateway/32" comment~$routingComment];
				:if ([:len $id] = 1) do={
					:local data [/ip/route/get $id];
					:if ($routingGateway = ($data->"gateway")) do={
						/log/info "El gateway ($routingGateway) para la ruta recursiva ($recursiveGateway) no ha cambiado.";
					} else={
						/ip/route/set $id gateway=$routingGateway;
					}
				}
			}
		}
	}	
}