{

	:local segmentIPv4;
	:set segmentIPv4 do={
		:local ipAddress [:tostr $1];
		:local segment ({});
	
		:local slash [:find $1 "/"];
		:if ($slash >= 0) do={
			:local ipAddress [:pick $1 0 $slash];
			:local cidr [:tonum [:pick $1 ($slash + 1) [:len $1]]];
			:if (($cidr >= 0) && ($cidr <= 32)) do={
				:if ([:typeof [:toip $ipAddress]] = "ip") do={
					:set segment {"address"=$ipAddress; "cidr"=$cidr};
				}
			}
		}
		:return $segment;
	}
	
	:local choice do={
		:local option -1;
		:local calcelOption 0;
		
		:local paramChoices [:toarray $choices];
		:local paramTitle [:tostr $title];
		:local paramPrompt [:tostr $prompt];
		:local paramCancellable true;

		:local minChoice 0;
		:local maxChoice [:len $paramChoices];
				
		:while (!(($option >=$minChoice) && ($option <= $maxChoice))) do={
			:set option 0;
			:put "";
			:if ([:len $paramTitle] > 0) do={
				:put $paramTitle;
				:put "";
			}
			:foreach choiceOption in=$paramChoices do={
				:put "$option - $choiceOption";
				:set option ($option + 1);
			}
			:if ($paramCancellable) do={
				:set calcelOption $option;
				:put "$option - Cancelar";
				:set option ($option + 1);
			}
			:put "";
			:set option [:tonum [/terminal/ask prompt=$paramPrompt]];
			:if ($option = $calcelOption) do={
				:return -1;
			}
		}
		
		:return $option;
	}
	
	:local bridge ({"nat"=true});
	:local option;
	
	:local findIds [/interface/bridge/find];
	
	:local choiceOption ({}); #{"Crear un bridge"};
	:foreach id in=$findIds do={
		:local valueId [/interface/bridge/get $id name];
		:set choiceOption ($choiceOption, $valueId);
	}
	
	#BRIDGE
	:set option [$choice choices=$choiceOption prompt="Selecciona el bridge para el contenedor o crea uno nuevo: " title="Selecciona una opcion: "];
	:set ($bridge->"name") ($choiceOption->$option);
	
	:local findIds [/ip/address/find where !dynamic interface=($bridge->"name")];
	:set choiceOption ({});
	:foreach id in=$findIds do={
		:local valueId [/ip/address/get $id address];
		:set choiceOption ($choiceOption, $valueId);
	}
	:set option [$choice choices=$choiceOption prompt="Selecciona el address del bridge: " title="Selecciona una opcion: "];
	:set bridge ($bridge, [$segmentIPv4 ($choiceOption->$option)]);
	
	:put $bridge;
	
}

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
