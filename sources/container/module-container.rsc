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

		:local dockerName ($container->"name");
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
		:put "\nIniciando instalacion del docker: $dockerName ($remoteImage).";

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
		
		:put "\nRemoviendo reenvios de puertos configurados previamente para: container-$dockerName";
		/ip/firewall/nat/remove [find where comment~"container-$dockerName"];
		
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
					/ip/firewall/nat/add chain="container-$dockerName-$proto" protocol=$proto dst-port=$dsTport action=dst-nat to-addresses=($container->"address") to-ports=$toPort \
					comment="container-$dockerName-$proto $dsTport -> $toPort";
				}
				:local fId (([/ip/firewall/nat/find where chain="container-$dockerName-$proto"])->0);
				/ip/firewall/nat/add chain=dstnat action=jump jump-target="container-$dockerName-$proto" protocol=$proto dst-port=$dsTports place-before=$fId \
				comment="jump to container-$dockerName-$proto";
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
		:local installDir "$rootDir/containers/$dockerName";
		:local mountDir "$rootDir/mounts/$dockerName";

		:local etherName "veth-$dockerName";
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
		
		:put "Verificando si existe el contenedor ($dockerName) intalado previamente.";
		
		:local containerId [/container/find where root-dir=$installDir];
		:if ([:len $containerId] > 0) do={
			:put "Eliminando contenerdor: $dockerName...";
			/container/remove $containerId;
			:set containerId [/container/find where root-dir=$installDir];
		}
		:if ([:len $containerId] = 0) do={
			:put "Creando enviroment: $dockerName";

			#ENVIROMENT
			/container/envs/remove [find where name=$dockerName];
			
			:foreach k,v in=$enviroment do={
				:put "Nombre / valor: $k / $v";
				/container/envs/add name=$dockerName key=$k value=$v;
			}

			#MOUNTS
			:local mountsName "";
			
			:if ($reMount) do={
				:foreach id in=[/container/mounts/find where name~"^$dockerName"] do={
					/container/mounts/remove $id;
				}
				:foreach k,v in=$mounts do={
					:put "Creando punto de montaje: $dockerName-$k, $mountDir/$k: $v.";
					/container/mounts/add name="$dockerName-$k" src="$mountDir/$k" dst=$v;
					:if ([:len $mountsName] > 0) do={
						:set mountsName "$mountsName,$dockerName-$k";
					} else={
						:set mountsName "$dockerName-$k";
					}
				}
			}

			:put "\nCreando el contenedor: $dockerName, root-dir: $installDir.";
			:put "Buscando archivo de imagen: $imageFile.";
							
			:if ([:len [/file/find where name=$imageFile]] > 0) do={
				:put "Instalando desde archivo de imagen.";
				/container/add file=$imageFile interface=$etherName root-dir=$installDir mounts=$mountsName envlist=$dockerName \
				comment=($dockerName . " - " . $etherAddress) logging=yes cmd=$dockerCmd entrypoint=$dockerEntrypoint \
				hostname=($container->"hostname") domain-name=($container->"domain-name") dns=($container->"dns") workdir=($container->"workdir") \
				stop-signal=($container->"stop-signal") start-on-boot=($container->"start-on-boot");
			} else={
				:put "Archivo de imagen no encontrado, instalando desde imagen remota: $remoteImage.";
				/container/add remote-image=$remoteImage interface=$etherName root-dir=$installDir mounts=$mountsName envlist=$dockerName \
				comment=($dockerName . " - " . $etherAddress) logging=yes cmd=$dockerCmd entrypoint=$dockerEntrypoint \
				hostname=($container->"hostname") domain-name=($container->"domain-name") dns=($container->"dns") workdir=($container->"workdir") \
				stop-signal=($container->"stop-signal") start-on-boot=($container->"start-on-boot");
			}
			
			:put "";
			/container/print where root-dir=$installDir;
			:put "";

			#POST
		} else={
			:put "No se pudo eliminar el contenedor ($dockerName) intalado previamente, cancelada la instalacion.";
		}

	} else={
		:put "Por favor verifique los parametros.";
	}
}

:global unregisterContainer;
:set unregisterContainer do={
	:local dockerName $1;
	:local etherName "veth-$dockerName";

	:put "\nIniciando desinstalacion del docker: $dockerName.";

	:put "\nRemoviendo reenvios de puertos configurados previamente para: container-$dockerName";

	/ip/firewall/nat/remove [find where comment~"container-$dockerName"];
	
	:put "\nRemoviendo interface virtual del bridge: $etherName";
	
	/interface/bridge/port/remove [find where interface=$etherName];

	:put "\nRemoviendo interface virtual: $etherName";
	
	/interface/veth/remove [find where name=$etherName];
	
	:put "\nEliminando contenerdor: $dockerName.";
	
	/container/remove [find where comment~"^$dockerName"];
	
	:put "\nRemoviendo enviroment: $dockerName";

	/container/envs/remove [find where name=$dockerName];
	
	:put "\nRemoviendo mounts: $dockerName";
	
	/container/mounts/remove [find where name~"^$dockerName"];
	
	:put "\nDesinstalacion del docker $dockerName finalizada.";
	:put "\n";
}
