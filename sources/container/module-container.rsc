#Version: 7.0
#Fecha: 26-06-2022
#RouterOS 7.16 y superior.
#Comentario: Modulo para registro de containers.

:global registerContainer;
:set registerContainer do={
	
	:if (([:typeof $bridge] = "array") && ([:typeof $disk] = "array") && ([:typeof $container] = "array")) do={


		#BRIDGE-PARAM
		:local dockerBridge ($bridge->"name");
		:local dockerBridgeAddress ($bridge->"address");
		:local cidr ($bridge->"cidr");

		#CONTAINER-PARAM

		:local containerName ($container->"name");
		:local remoteImage ($container->"remote-image");
		:local etherAddress (($container->"address") . "/$cidr");

		:local dockerCmd ($container->"cmd");
		:local dockerEntrypoint ($container->"entrypoint");

		#ENVIROMENT-PARAM
		:local enviroment ($container->"enviroment");

		#MOUNTS-PARAM
		:local reMount ($container->"re-mount");
		:local mounts ($container->"mounts");

		#BRIDGE
		:put "\nIniciando instalacion del docker: $containerName ($remoteImage).";

		:local idBridge [/interface/bridge/find where name=$dockerBridge];
		:if ([:len $idBridge] = 0) do={
			:put "Creando bridge: $dockerBridge ($dockerBridgeAddress/$cidr).";
			/interface/bridge/add name=$dockerBridge comment=$dockerBridge;
			/ip/address/add address="$dockerBridgeAddress/$cidr" interface=$dockerBridge comment=$dockerBridge;
		} else={
			:local interfaceAddress [/ip/address/get [find where interface=$dockerBridge] address];
			:put "Bridge configurado previamente: $dockerBridge ($interfaceAddress).";
		}
		
		#FIREWALL
		:if (($bridge->"nat")) do={
			:local dockerNetwork ([/ip/address/get [find where interface=$dockerBridge] network] . "/$cidr");

			:if ([:len [/ip/firewall/nat/find where chain=srcnat action=masquerade src-address=$dockerNetwork]] = 0) do={
				:put "Creando regla firewall srcnat masquerade: $dockerNetwork.";
				/ip/firewall/nat/add chain=srcnat action=masquerade src-address=$dockerNetwork comment=$dockerBridge;
			} else={
				:put "Regla firewall srcnat masquerade configurado previamente: $dockerNetwork.";
			}			
		}
		
		:put "\nRemoviendo reenvios de puertos configurados previamente para: container-$containerName";
		/ip/firewall/nat/remove [find where comment~"container-$containerName"];
		
		:if (($container->"nat")) do={
		
			:local ports ($container->"ports");
			
			:foreach proto,port in=$ports do={
				:local dsTports "";
				:foreach dsTport,toPort in=$port do={
					:put "Agregando redireccion de puerto $proto: $dsTport -> $toPort";
					:if ([:len $dsTports] > 0) do={
						:set dsTports "$dsTports,$dsTport";
					} else={
						:set dsTports "$dsTport";
					}
					/ip/firewall/nat/add chain="container-$containerName-$proto" protocol=$proto dst-port=$dsTport action=dst-nat to-addresses=($container->"address") to-ports=$toPort \
					comment="container-$containerName-$proto $dsTport -> $toPort";
				}
				:local fId (([/ip/firewall/nat/find where chain="container-$containerName-$proto"])->0);
				/ip/firewall/nat/add chain=dstnat action=jump jump-target="container-$containerName-$proto" protocol=$proto dst-port=$dsTports place-before=$fId \
				comment="jump to container-$containerName-$proto";
			}
		}		

		#CONTAINER

		:local diskName "";
		:local diskId [/disk/find where fs-label=($disk->"label")];
		:if ([:len $diskId] = 0) do={
			:local diskId [/disk/find where slot=($disk->"name")];
		}
		:if ([:len $diskId] > 0) do={
			:set diskName ([/disk/get $diskId slot] . "/");
		}
		
		:local rootDir ("$diskName" . ($disk->"install-dir"));
		:local imageFile ("$rootDir/" . ($disk->"image-dir") . "/" . ($container->"file"));
		:local installDir "$rootDir/containers/$containerName";
		:local mountDir "$rootDir/mounts/$containerName";

		:local etherName "veth-$containerName";
		:local etherGateway $dockerBridgeAddress;
		
		:put "\nCreando/actualizando interface virtual: $etherName, address: $etherAddress, gateway: $etherGateway";
		
		:local interfaceId [/interface/veth/find where name=$etherName];
		:if ([:len $interfaceId] = 0) do={
			/interface/veth/add name=$etherName address=$etherAddress gateway=$etherGateway;
			/interface/bridge/port/add bridge=$dockerBridge interface=$etherName;
		} else={
			/interface/veth/set $interfaceId address=$etherAddress gateway=$etherGateway;
			:set interfaceId [/interface/bridge/port/find where interface=$etherName];
			:if ([:len $interfaceId] = 0) do={
				/interface/bridge/port/add bridge=$dockerBridge interface=$etherName;
			} else={
				/interface/bridge/port/set $interfaceId bridge=$dockerBridge;
			}
		}
		
		:put "Verificando si existe el contenedor ($containerName) intalado previamente.";
		
		:local containerId [/container/find where root-dir=$installDir];
		:if ([:len $containerId] > 0) do={
			:put "Eliminando contenerdor: $containerName...";
			/container/remove $containerId;
			:set containerId [/container/find where root-dir=$installDir];
		}
		:if ([:len $containerId] = 0) do={
			:put "Creando enviroment: $containerName";

			#ENVIROMENT
			/container/envs/remove [find where name=$containerName];
			
			:foreach k,v in=$enviroment do={
				:put "Nombre / valor: $k / $v";
				/container/envs/add name=$containerName key=$k value=$v;
			}

			#MOUNTS
			:local mountsName "";
			
			:if ($reMount) do={
				:foreach id in=[/container/mounts/find where name~"^$containerName"] do={
					/container/mounts/remove $id;
				}
				:foreach k,v in=$mounts do={
					:put "Creando punto de montaje: $containerName-$k, $mountDir/$k: $v.";
					/container/mounts/add name="$containerName-$k" src="$mountDir/$k" dst=$v;
					:if ([:len $mountsName] > 0) do={
						:set mountsName "$mountsName,$containerName-$k";
					} else={
						:set mountsName "$containerName-$k";
					}
				}
			}

			:put "\nCreando el contenedor: $containerName, root-dir: $installDir.";
			:put "Buscando archivo de imagen: $imageFile.";
							
			:if ([:len [/file/find where name=$imageFile]] > 0) do={
				:put "Instalando desde archivo de imagen.";
				/container/add file=$imageFile interface=$etherName root-dir=$installDir mounts=$mountsName envlist=$containerName \
				comment=($containerName . " - " . $etherAddress) logging=yes cmd=$dockerCmd entrypoint=$dockerEntrypoint \
				hostname=($container->"hostname") domain-name=($container->"domain-name") dns=($container->"dns") workdir=($container->"workdir") \
				stop-signal=($container->"stop-signal") start-on-boot=($container->"start-on-boot");
			} else={
				:put "Archivo de imagen no encontrado, instalando desde imagen remota: $remoteImage.";
				/container/add remote-image=$remoteImage interface=$etherName root-dir=$installDir mounts=$mountsName envlist=$containerName \
				comment=($containerName . " - " . $etherAddress) logging=yes cmd=$dockerCmd entrypoint=$dockerEntrypoint \
				hostname=($container->"hostname") domain-name=($container->"domain-name") dns=($container->"dns") workdir=($container->"workdir") \
				stop-signal=($container->"stop-signal") start-on-boot=($container->"start-on-boot");
			}
			
			:put "";
			/container/print where root-dir=$installDir;
			:put "";

			#POST
		} else={
			:put "No se pudo eliminar el contenedor ($containerName) intalado previamente, cancelada la instalacion.";
		}

	} else={
		:put "Por favor verifique los parametros.";
	}
}

:global stopAndWaitContainer;
:set stopAndWaitContainer do={
	:local containerName $1;
	:local try 60;
	:local containerId [/container/find where name=$containerName];
	:local containerStatus "";
	:if ([:len $containerId] > 0) do={
		/container/stop $containerId;
		:set containerStatus [/container/get $containerId status];
		:while ((($containerStatus != "stopped") && ($containerStatus != "error")) && $try > 0) do={
			:put "Esperando por la parada del contenedor ($try)  ";
			/terminal/cuu count=2;
			:delay delay-time=1s;
			:set try ($try - 1);
			:set containerStatus [/container/get $containerId status];
		}
	}
	:return (($containerStatus = "stopped") || ($containerStatus = "error"));
}


:global unregisterContainer;
:set unregisterContainer do={
	:global stopAndWaitContainer;
	
	:local containerName $1;
	:local container [/container/print as-value where name=$containerName];
	
	:if ([:len $container] = 1) do={
		
		:local etherName ($container->0->"interface");

		:put "\nIniciando desinstalacion del contenedor $containerName.";
		
		:local isStop [$stopAndWaitContainer $containerName];
		:put "";
		
		:if ($isStop) do={

			:put "\nEliminando contenerdor $containerName.";
			
			/container/remove ($container->0->".id");

			:put ("\nRemoviendo enviroment: " . ($container->0->"envlist"));
			
			/container/envs/remove [find where name=($container->0->"envlist")];
			
			:foreach mount in=($container->0->"mounts") do={
				:put "\nRemoviendo mounts: $mount";
				/container/mounts/remove [find where name=$mount];
			}			
			
			:put "\nRemoviendo interface virtual del bridge: $etherName";
			
			/interface/bridge/port/remove [find where interface=$etherName];

			:put "\nRemoviendo interface virtual: $etherName";
			
			/interface/veth/remove [find where name=$etherName];

			:put "\nRemoviendo reenvios de puertos configurados previamente para el contenedor $containerName";

			/ip/firewall/nat/remove [find where comment~"container-$containerName"];
			
			:put "\nDesinstalacion del contenedor $containerName finalizada.";
			:put "\n";
		} else={
			:put "\nNo se ha podido detener el contenedor $containerName.";
			:put "\n";			
		}
	} else={
		:put "\nContenedor $containerName no encontrado.";
		:put "\n";
	}
}

