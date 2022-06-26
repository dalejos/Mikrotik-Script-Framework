
#BRIDGE-PARAM
:local dockerBridge "docker";
:local dockerBridgeAddress "10.11.12.1";
:local cidr "24";

#CONTAINER-PARAM
:local rootDir "disk1/docker";

:local dockerName "syslog-ng";
:local remoteImage "linuxserver/syslog-ng:latest";
:local etherAddress "10.11.12.5/$cidr";

:local dockerCmd "";
:local dockerEntrypoint "";

#ENVIROMENT-PARAM
:local enviroment ({});
:set ($enviroment->"TZ") "America/Caracas";
#:set ($enviroment->"PUID") "1000";
#:set ($enviroment->"PGID") "1000";

#MOUNTS-PARAM
:local mounts ({});
:set ($mounts->"config") "/config";
:set ($mounts->"log") "/var/log";

#BRIDGE
:if ([:len [/interface/bridge/find where name=$dockerBridge]] = 0) do={
	/interface/bridge/add name=$dockerBridge;
	/ip/address/add address="$dockerBridgeAddress/$cidr" interface=$dockerBridge;
}

:local dockerNetwork ([/ip/address/get [find where interface=$dockerBridge] network] . "/$cidr");

:if ([:len [/ip/firewall/nat/find where chain=srcnat action=masquerade src-address=$dockerNetwork]] = 0) do={
	/ip/firewall/nat/add chain=srcnat action=masquerade src-address=$dockerNetwork;
}

#CONTAINER
:local installDir "$rootDir/$dockerName/root";
:local mountDir "$rootDir/$dockerName/mount";

:local etherName "veth-$dockerName";
:local etherGateway $dockerBridgeAddress;

/interface/veth/add name=$etherName address=$etherAddress gateway=$etherGateway;
/interface/bridge/port add bridge=$dockerBridge interface=$etherName;

#ENVIROMENT
:foreach k,v in=$enviroment do={
	/container/envs/add list=$dockerName name=$k value=$v;
}

#MOUNTS
:local mountsName "";

:foreach k,v in=$mounts do={
	/container/mounts/add name="$dockerName-$k" src="$mountDir/$k" dst=$v;
	:if ([:len $mountsName] > 0) do={
		:set mountsName "$mountsName,$dockerName-$k";
	} else={
		:set mountsName "$dockerName-$k";
	}
}

/container/add remote-image=$remoteImage interface=$etherName root-dir=$installDir mounts=$mountsName envlist=$dockerName \
comment=$dockerName logging=yes cmd=$dockerCmd entrypoint=$dockerEntrypoint;

/container/print where root-dir=$installDir;

#POST