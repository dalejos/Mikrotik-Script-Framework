{
	:local askRoutingTable do={
		:return [/terminal/ask prompt="Ingresa el nombre de la nueva routing table:"];
	}
	
	:local askIdRoutingTable do={
		:return [/terminal/ask prompt="Selecciona una routing table, 0 para crear una nueva:"];
	}
	
	:local askIPs do={
		:return [:toarray [/terminal/ask prompt=$1]];
	}

	:local askNum do={
		:return [:tonum [/terminal/ask prompt=$1]];
	}

	:local askIP do={
		:return [:toip [/terminal/ask prompt=$1]];
	}

	:local routingTables [/routing/table/print as-value proplist=name where !dynamic fib];
	:local routingTable "";
	:local addRoutingTable false;
	
	:if ([:len $routingTables] > 0) do={
		:local tableId 1;
		:put "";
		:put "Routing tables existentes: "
		:foreach table in=$routingTables do={
			:put ("$tableId - " . ($table->"name"));
			:set tableId ($tableId + 1);
		}
		:put "";
		:local idTable [$askIdRoutingTable];
		
		:if ($idTable > 0) do={
			:set idTable ($idTable - 1);
			:set routingTable ($routingTables->$idTable->"name");
		} else={
			:set routingTable [$askRoutingTable];
			:set addRoutingTable true;
		}
		
	} else={
		:set routingTable [$askRoutingTable];
		:set addRoutingTable true;
	}
	
	:local ispNumber [$askNum "Ingrese la prioridad del ISPs, ejemplo 1:"];
	:local recursiveGateways [$askIPs "Ingrese gateways recursivos, ejemplo 1.1.1.1,1.0.0.1:"];
	:local maxRecursiveGateways [$askNum "Ingrese la cantidad maxima de gateways recursivos a usar:"];
	:local backupGateways [$askIPs "Ingrese gateways de backup, ejemplo 8.8.8.8,8.8.4.4:"];
	:local routingGateway [$askIP "Ingrese la IP del gateway para esta ruta, ejemplo 172.16.2.1:"];;
	
	#EJECUTAR CONFIGURACION
	
	:put "";
	:put "Creando configuracion...";
	
	:if ($addRoutingTable) do={
		:put "Agregando routing table: $routingTable";
		/routing/table/add name=$routingTable fib;
	} else={
		:put "Se selecciono la routing table: $routingTable";
	}
	
	:put ("Prioridad de ruta para este ISP: $ispNumber");
	:put ("Gateways recursivos: " . [:tostr $recursiveGateways]);
	:put ("Cantidad maxima de gateways recursivos a usar: $maxRecursiveGateways");
	:put ("Gateways de backup: " . [:tostr $backupGateways]);
	:put ("Gateway para esta ruta: $routingGateway");
	
##################################################################################

	:local autoRemove true;
	:local forceRemove true;
	:local routingDisabled "yes";

	:local routingComment "$routingTable";
	:local routingDistance ($ispNumber * $maxRecursiveGateways);
	
	:if ($maxRecursiveGateways > 1) do={
		:set routingDistance ($routingDistance - 1);
	}
	
	:local bound 1;
	
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