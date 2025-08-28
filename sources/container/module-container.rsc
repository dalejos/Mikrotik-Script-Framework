#Version: 7.0
#Fecha: 26-06-2022
#RouterOS 7.20 y superior.
#Comentario: Modulo para registro de containers.

:global registerContainer;
:set registerContainer do={
	
	:if (([:typeof $bridge] = "array") && ([:typeof $disk] = "array") && ([:typeof $container] = "array")) do={
	
		:local containerName ($container->"name");

		:local containerId [/container/find where name=$containerName];
		
		:if ([:len $containerId] = 0) do={

			#BRIDGE-PARAM
			:local bridgeName ($bridge->"name");

			:local setupIPv4 ([:len ($bridge->"ipv4")] > 0)
			:local setupIPv6 ([:len ($bridge->"ipv6")] > 0);
			
			:local bridgeIPv4Address [:tostr [:toip ($bridge->"ipv4"->"address")]];;
			:local bridgeIPv4Cidr ($bridge->"ipv4"->"cidr");
			:local bridgeIPv4Nat ($bridge->"ipv4"->"nat");
			
			:local bridgeIPv6Address [:tostr [:toip6 ($bridge->"ipv6"->"address")]];
			:local bridgeIPv6Cidr ($bridge->"ipv6"->"cidr");		
			
			#CONTAINER-PARAM
			:local remoteImage ($container->"remote-image");			
			:local containerAddress [:toarray ($container->"address")];
			
			:for i from=0 to=([:len $containerAddress] - 1) do={
				:local item ($containerAddress->$i);
				:if ([:toip $item]) do={
					:set ($containerAddress->$i) "$item/$bridgeIPv4Cidr";
				} else={
					:if ([:toip6 $item]) do={
						:set ($containerAddress->$i) "$item/$bridgeIPv6Cidr";
					}
				}
			}

			:local vethAddress [:serialize $containerAddress to=dsv delimiter=","];

			:local dockerCmd ($container->"cmd");
			:local dockerEntrypoint ($container->"entrypoint");

			#ENVIROMENT-PARAM
			:local enviroment ($container->"enviroment");

			#MOUNTS-PARAM
			:local reMount ($container->"re-mount");
			:local mounts ($container->"mounts");

			#BRIDGE
			:put "\nIniciando instalacion del docker: $containerName ($remoteImage).";
			
			:local idBridge [/interface/bridge/find where name=$bridgeName];
			
			:if ([:len $idBridge] = 0) do={
				:put "Creando bridge: $bridgeName.";
				/interface/bridge/add name=$bridgeName comment=$bridgeName;
			} else={
				:put "Bridge configurado previamente: $bridgeName.";
			}
			
			#SET IPV4
			:if ($setupIPv4) do={
				:local interfaceAddress [/ip/address/print as-value where interface=$bridgeName address="$bridgeIPv4Address/$bridgeIPv4Cidr"];
				:if ([:len $interfaceAddress] > 0) do={
					:put ("IPv4 configurado previamente: $bridgeName " . ($interfaceAddress->0->"address") . ".");
				} else={
					:put "Configurando IPv4: $bridgeName ($bridgeIPv4Address/$bridgeIPv4Cidr).";
					/ip/address/add address="$bridgeIPv4Address/$bridgeIPv4Cidr" interface=$bridgeName comment=$bridgeName;
				}
			}
			
			#SET IPV6
			:if ($setupIPv6) do={
				:local interfaceAddress [/ipv6/address/print as-value where interface=$bridgeName address="$bridgeIPv6Address/$bridgeIPv6Cidr"];
				:if ([:len $interfaceAddress] > 0) do={
					:put ("IPv6 configurado previamente: $bridgeName " . ($interfaceAddress->0->"address") . ".");
				} else={
					:put "Configurando IPv6: $bridgeName ($bridgeIPv6Address/$bridgeIPv6Cidr).";
					/ipv6/address/add address="$bridgeIPv6Address/$bridgeIPv6Cidr" interface=$bridgeName comment=$bridgeName advertise=no;
				}
			}
			
			#FIREWALL DEFINIR SOLO SI ES IPV4
			:if ($bridgeIPv4Nat) do={
				:local dockerNetwork ([/ip/address/get [find where interface=$bridgeName] network] . "/$bridgeIPv4Cidr");

				:if ([:len [/ip/firewall/nat/find where chain=srcnat action=masquerade src-address=$dockerNetwork]] = 0) do={
					:put "Creando regla firewall srcnat masquerade: $dockerNetwork.";
					/ip/firewall/nat/add chain=srcnat action=masquerade src-address=$dockerNetwork comment=$bridgeName;
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

			:local vethName "veth-$containerName";
			:local vethIPv4Gateway $bridgeIPv4Address;
			:local vethIPv6Gateway $bridgeIPv6Address;
			
			:put "\nCreando/actualizando interface virtual: $vethName, address: $vethAddress, IPv4 gateway: $vethIPv4Gateway, IPVv6 gateway: $vethIPv6Gateway";
			
			:local interfaceId [/interface/veth/find where name=$vethName];
			:if ([:len $interfaceId] = 0) do={
				/interface/veth/add name=$vethName address=$vethAddress gateway=$vethIPv4Gateway gateway6=$vethIPv6Gateway;
				/interface/bridge/port/add bridge=$bridgeName interface=$vethName;
			} else={
				/interface/veth/set $interfaceId address=$vethAddress gateway=$vethIPv4Gateway gateway6=$vethIPv6Gateway;
				:set interfaceId [/interface/bridge/port/find where interface=$vethName];
				:if ([:len $interfaceId] = 0) do={
					/interface/bridge/port/add bridge=$bridgeName interface=$vethName;
				} else={
					/interface/bridge/port/set $interfaceId bridge=$bridgeName;
				}
			}
			
			:put "Verificando si existe el contenedor ($containerName) intalado previamente.";
		
			:put "Creando enviroment: $containerName";

			#ENVIROMENT
			/container/envs/remove [find where list=$containerName];
			
			:foreach k,v in=$enviroment do={
				:put "Nombre / valor: $k / $v";
				/container/envs/add list=$containerName key=$k value=$v;
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
				/container/add file=$imageFile interface=$vethName root-dir=$installDir mounts=$mountsName envlist=$containerName \
				comment=($containerName . " - " . $vethAddress) logging=yes cmd=$dockerCmd entrypoint=$dockerEntrypoint \
				hostname=($container->"hostname") domain-name=($container->"domain-name") dns=($container->"dns") workdir=($container->"workdir") \
				stop-signal=($container->"stop-signal") start-on-boot=($container->"start-on-boot") check-certificate=($container->"check-certificate") \
				memory-high=($container->"memory-high") user=($container->"user") auto-restart-interval=($container->"auto-restart-interval");
			} else={
				:put "Archivo de imagen no encontrado, instalando desde imagen remota: $remoteImage.";
				/container/add remote-image=$remoteImage interface=$vethName root-dir=$installDir mounts=$mountsName envlist=$containerName \
				comment=($containerName . " - " . $vethAddress) logging=yes cmd=$dockerCmd entrypoint=$dockerEntrypoint \
				hostname=($container->"hostname") domain-name=($container->"domain-name") dns=($container->"dns") workdir=($container->"workdir") \
				stop-signal=($container->"stop-signal") start-on-boot=($container->"start-on-boot") check-certificate=($container->"check-certificate") \
				memory-high=($container->"memory-high") user=($container->"user") auto-restart-interval=($container->"auto-restart-interval");
			}
			
			:put "";
			/container/print where root-dir=$installDir;
			:put "";

			#POST
		} else={
			:put "No se puede instalar un contenedor ($containerName) intalado previamente, cancelada la instalacion.";
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
	:local isStop true;
	
	:if ([:len $containerId] > 0) do={
		:set isStop [/container/get $containerId stopped];
		:do {
			/container/stop $containerId;
		} on-error={
		}
		:while (!($isStop) && ($try > 0)) do={
			:put "Esperando por la parada del contenedor ($try)  ";
			/terminal/cuu count=2;
			:delay delay-time=1s;
			:set try ($try - 1);
			:set isStop [/container/get $containerId stopped];
		}
	}
	:return $isStop;
}


:global unregisterContainer;
:set unregisterContainer do={
	:global stopAndWaitContainer;
	
	:local containerName $1;
	:local containerId [/container/find where name=$containerName];
	
	:if ([:len $containerId] > 0) do={
	
		:local container [/container/get $containerId];

		:put "\nIniciando desinstalacion del contenedor $containerName.";
		
		:local isStop [$stopAndWaitContainer $containerName];
		:put "";

		:if ($isStop) do={

			:put "\nEliminando contenerdor $containerName.";
			
			/container/remove ($container->".id");
			
			:foreach vInterface in=($container->"interface") do={
				:put "\nRemoviendo interface virtual del bridge: $vInterface";
				/interface/bridge/port/remove [find where interface=$vInterface];
				
				:put "\nRemoviendo interface virtual: $vInterface";
				/interface/veth/remove [find where name=$vInterface];
			}

			:foreach mount in=($container->"mounts") do={
				:put "\nRemoviendo mounts: $mount";
				/container/mounts/remove [find where name=$mount];
			}
			
			:foreach envlist in=($container->"envlists") do={
				:put "\nRemoviendo enviroment: $envlist";
				/container/envs/remove [find where list=$envlist];
			}
			
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

