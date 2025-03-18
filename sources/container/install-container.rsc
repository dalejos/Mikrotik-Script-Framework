{
	
	:local bridgeIds [/interface/bridge/find];

	:local option 0;
	:local bridgeCount [:len $bridgeIds];
	:do {
		:local returnOption 0;
		
		:set option 0;
		:put "";
		:put "Seleccionar o crear bridge.";
		:put "";
		:if ($bridgeCount > 0) do={
			:foreach id in $bridgeIds do={
				:local bridgeName [/interface/bridge/get $id name];
				:set option ($option + 1);
				:put "$option - $bridgeName";
			}
		}
		:set option ($option + 1);
		:set returnOption $option;
		:put "$option - Cancelar";
		:put "";
		:set option [:tonum [/terminal/ask prompt="Selecciona el bridge para el contenedor, 0 para crear uno nuevo: "]];
		:if ($option = $returnOption) do={
			:return "";
		}
	} while (!(($option >=0) && ($option <= $bridgeCount)));
	:put "Opcion: $option";
}

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
:set ($disk->"install-dir") "docker";
:set ($disk->"image-dir") "images";

#CONTAINER
:local container ({});
:set ($container->"name") "pihole";
:set ($container->"file") (($container->"name") . ".tar");
:set ($container->"remote-image") "pihole/pihole:latest";
:set ($container->"address") "10.11.12.2";
:set ($container->"cmd") "";
:set ($container->"entrypoint") "";
:set ($container->"domain-name") "docker.lan";
:set ($container->"hostname") ($container->"name");
:set ($container->"logging") yes;
:set ($container->"stop-signal") "15";
:set ($container->"comment") ($container->"name");
:set ($container->"dns") "";
:set ($container->"workdir") "";
:set ($container->"start-on-boot") false;

:set ($container->"nat") true;
:set ($container->"re-mount") true;

#ENVIROMENT
:local enviroment ({});
:set ($enviroment->"TZ") "America/Caracas";
:set ($enviroment->"WEBPASSWORD") "123456";
:set ($enviroment->"DNSMASQ_USER") "root";

#MOUNTS
:local mounts ({});
:set ($mounts->"etc") "/etc/pihole";
:set ($mounts->"dnsmasq.d") "/etc/dnsmasq.d";

#PORTS
:local ports ({});

#REGISTER
:set ($container->"enviroment") $enviroment;
:set ($container->"mounts") $mounts;
:set ($container->"ports") $ports;

:global registerContainer;
[$registerContainer bridge=$bridge disk=$disk container=$container];
