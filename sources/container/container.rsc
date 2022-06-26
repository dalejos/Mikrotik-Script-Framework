
#BRIDGE
:local bridge ({});
:set ($bridge->"name") "docker";
:set ($bridge->"address") "10.11.12.1";
:set ($bridge->"cidr") "24";
:set ($bridge->"nat") true;

#DISK
:local disk ({});
:set ($disk->"label") "docker";
:set ($disk->"name") "";

#CONTAINER
:local container ({});
:set ($container->"name") "pihole";
:set ($container->"remote-mage") "pihole/pihole:latest";
:set ($container->"file") "";
:set ($container->"address") "10.11.12.2";
:set ($container->"cmd") "";
:set ($container->"entrypoint") "";
:set ($container->"domain-name") "docker.lan";
:set ($container->"hostname") ($container->"name");
:set ($container->"logging") yes;
:set ($container->"stop-signal") "";
:set ($container->"comment") "";
:set ($container->"dns") "";
:set ($container->"workdir") "";
:set ($container->"re-mount") true;

#ENVIROMENT
:local enviroment ({});
:set ($enviroment->"TZ") "America/Caracas";
:set ($enviroment->"WEBPASSWORD") "123456";
:set ($enviroment->"DNSMASQ_USER") "root";

#MOUNTS
:local mounts ({});
:set ($mounts->"etc") "/etc/pihole";
:set ($mounts->"etc-dnsmasq.d") "/etc/dnsmasq.d";

#REGISTER
:set ($container->"enviroment") $enviroment;
:set ($container->"mounts") $mounts;

:global registerContainer;
[$registerContainer bridge=$bridge disk=$disk container=$container];


:global registerContainer;
:set registerContainer do={
	
	:if ([:typeof $container] = "array") do{


		#BRIDGE-PARAM
		:local dockerBridge "docker";
		:local dockerBridgeAddress "10.11.12.1";
		:local cidr "24";

		#CONTAINER-PARAM
		:local diskLabelOrName "docker";

		:local dockerName "pihole";
		:local remoteImage "pihole/pihole:latest";
		:local etherAddress "10.11.12.2/$cidr";

		:local dockerCmd "";
		:local dockerEntrypoint "";

		#ENVIROMENT-PARAM
		:local enviroment ({});
		:set ($enviroment->"TZ") "America/Caracas";
		:set ($enviroment->"WEBPASSWORD") "123456";
		:set ($enviroment->"DNSMASQ_USER") "root";

		#MOUNTS-PARAM
		:local reMount true;
		:local mounts ({});
		:set ($mounts->"etc") "/etc/pihole";
		:set ($mounts->"etc-dnsmasq.d") "/etc/dnsmasq.d";

		#BRIDGE
		:put "\nIniciando instalacion del docker: $dockerName ($remoteImage).";

		:local idBridge [/interface/bridge/find where name=$dockerBridge];
		:if ([:len $idBridge] = 0) do={
			:put "Creando bridge: $dockerBridge ($dockerBridgeAddress/$cidr).";
			/interface/bridge/add name=$dockerBridge;
			/ip/address/add address="$dockerBridgeAddress/$cidr" interface=$dockerBridge;
		} else={
			:local interfaceAddress [/ip/address/get [find where interface=$dockerBridge] address];
			:put "Bridge configurado previamente: $dockerBridge ($interfaceAddress).";
		}

		:local dockerNetwork ([/ip/address/get [find where interface=$dockerBridge] network] . "/$cidr");

		:if ([:len [/ip/firewall/nat/find where chain=srcnat action=masquerade src-address=$dockerNetwork]] = 0) do={
			:put "Creando regla firewall srcnat masquerade: $dockerNetwork.";
			/ip/firewall/nat/add chain=srcnat action=masquerade src-address=$dockerNetwork;
		} else={
			:put "Regla firewall srcnat masquerade configurado previamente: $dockerNetwork.";
		}

		#CONTAINER

		:local diskId [/disk/find where label=$diskLabelOrName];
		:if ([:len $diskId] = 0) do={
			:local diskId [/disk/find where name=$diskLabelOrName];
		}

		:if ([:len $diskId] > 0) do={
			:local diskName [/disk/get $diskId name];
			:local rootDir "$diskName/docker";
			:local installDir "$rootDir/$dockerName/root";
			:local mountDir "$rootDir/$dockerName/mount";

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
				:foreach id in=[/container/envs/find where list=$dockerName] do={
					/container/envs/remove $id;
				}
				:foreach k,v in=$enviroment do={
					:put "Nombre / valor: $k / $v";
					/container/envs/add list=$dockerName name=$k value=$v;
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

				:put "\nCreando el contenedor: $dockerName ($remoteImage), root-dir: $installDir.";
				/container/add remote-image=$remoteImage interface=$etherName root-dir=$installDir mounts=$mountsName envlist=$dockerName \
				comment=$dockerName logging=yes cmd=$dockerCmd entrypoint=$dockerEntrypoint;
				
				:put "";
				/container/print where root-dir=$installDir;
				:put "";

				#POST
			} else={
				:put "No se pudo eliminar el contenedor ($dockerName) intalado previamente, cancelada la instalacion.";
			}
		} else={
			:put "No se encontro disco para instalacion con label/name: $diskLabelOrName.";
		}

	}
}
