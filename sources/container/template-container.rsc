#BRIDGE
:local bridge ({});
:set ($bridge->"bridge") "containers";
:set ($bridge->"ipv4-nat") true;

#DISK
:local disk ({});

:set ($disk->"fs-label") "containers";
:set ($disk->"slot") "";
:set ($disk->"root-dir") "containers";
:set ($disk->"install-dir") "apps";
:set ($disk->"mounts-dir") "mounts";
:set ($disk->"images-dir") "images";

#CONTAINER
:local container ({});

:set ($container->"name") "adguardhome";
:set ($container->"comment");
:set ($container->"file") "adguardhome.tar";
:set ($container->"remote-image") "adguard/adguardhome:latest";
:set ($container->"check-certificate") "no";
:set ($container->"cmd");
:set ($container->"entrypoint");
:set ($container->"workdir");
:set ($container->"hostname") ($container->"name");
:set ($container->"domain-name") "containers.lan";
:set ($container->"dns");
:set ($container->"memory-high") "unlimited";
:set ($container->"stop-signal") 15;
:set ($container->"user");
:set ($container->"logging") "yes";
:set ($container->"start-on-boot") "no";
:set ($container->"auto-restart-interval");

:set ($container->"nat") true;
:set ($container->"re-mount") true;

#INTERFACE
:local interfaceList ({});
:local interface ({});

#:set ($interface->"name");
:set ($interface->"name") "-dual-stack";
:set ($interface->"mac-address");
:set ($interface->"address") "10.11.12.254/24, fd17:fa22:2edf::ffff/64";
:set ($interface->"gateway") 10.11.12.1;
:set ($interface->"gateway6") fd17:fa22:2edf::1;
:set ($interface->"dhcp");
:set ($interface->"bridge") $bridge;
:set interfaceList ($interfaceList, {$interface});

:set interface ({});
:set ($interface->"name") "internal";
:set ($interface->"dhcp") "yes";

:set interfaceList ($interfaceList, {$interface});


#MOUNTS
:local mountList ({});
:local mount ({});

:set ($mount->"name") "-conf";
:set ($mount->"dst") "/opt/adguardhome/conf";
:set mountList ($mountList, {$mount});

:set mount ({});
:set ($mount->"name") "-work";
:set ($mount->"dst") "/opt/adguardhome/work";
:set mountList ($mountList, {$mount});

:set mount ({});
:set ($mount->"name") "common";
:set ($mount->"dst") "/opt/adguardhome";
:set mountList ($mountList, {$mount});

:set mount ({});
:set ($mount->"name");
:set ($mount->"dst") "/opt/adguardhome";
:set mountList ($mountList, {$mount});

#ENVIROMENT
:local enviromentList ({});
:local enviroment ({});

:set enviroment ({"list"=""; "key"="TZ"; "value"="America/Caracas"});
:set enviromentList ($enviromentList, {$enviroment});

:set enviroment ({"list"=""; "key"="PGID"; "value"="999"});
:set enviromentList ($enviromentList, {$enviroment});

:set enviroment ({"list"=""; "key"="PUID"; "value"="999"});
:set enviromentList ($enviromentList, {$enviroment});

:set enviroment ({"list"="common"});
:set enviromentList ($enviromentList, {$enviroment});

#DEVICES
:local devicesList ({});

#:set devicesList ($devicesList, "0-0");
#:set devicesList ($devicesList, "1-0");

#PORTS
:local portList ({});
	

#REGISTER
:set ($container->"interface") $interfaceList;
:set ($container->"mounts") $mountList;
:set ($container->"envlists") $enviromentList;
:set ($container->"devices") $devicesList;
:set ($container->"ports") $portList;

:global registerContainer;
[$registerContainer disk=$disk container=$container];
