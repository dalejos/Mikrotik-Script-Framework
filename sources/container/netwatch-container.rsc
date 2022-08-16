#VARIBLES DISPONOBLES
#host, since, status

#ON TEST RUNNING
:if ($status = "down") do={
	:local virtualInterface [/interface/veth/get [find where address~"$host/"]];
	:if ($virtualInterface) do={
		:local id [/container/find where interface=$virtualInterface->"name"];
		:if ([:len $id] = 1) do={
			:local container [/container/get $id];
			/log/info ("Iniciando contenedor: " . $container->"hostname" . " - ($host), " . $container->"name" . ".");
			/container/start $id;
		} else={
			/log/warning ("No se pudo encontrar un unico container para la interface: " . $virtualInterface->"name" . ".")
		}
	} else={
		/log/warning ("Interfaz virtual no encontrada para el host: $host.");
	}
}

#ON TEST DNS
#:local host 10.11.12.2;
#:local status "up";
:local domainName $host;

:if ($status = "up") do={
	:do {
		/resolve domain-name=$domainName server=$host;
	} on-error={
		/log/error "Servidor DNS no responde.";
	}
} else={
	:local virtualInterface [/interface/veth/get [find where address~"$host/"]];
	:if ($virtualInterface) do={
		:local id [/container/find where interface=$virtualInterface->"name"];
		:if ([:len $id] = 1) do={
			:local container [/container/get $id];
			/log/info ("Iniciando contenedor: " . $container->"hostname" . " - ($host), " . $container->"name" . ".");
			/container/start $id;
		} else={
			/log/warning ("No se pudo encontrar un unico container para la interface: " . $virtualInterface->"name" . ".")
		}
	} else={
		/log/warning ("Interfaz virtual no encontrada para el host: $host.");
	}
}

#ON UP
/ip/firewall/nat/set [find where comment="REDIRECT DNS"] disabled=yes;

#ON DOWN
/ip/firewall/nat/set [find where comment="REDIRECT DNS"] disabled=no;

