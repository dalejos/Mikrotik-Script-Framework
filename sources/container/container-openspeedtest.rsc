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

:set ($container->"name") "openspeedtest";
:set ($container->"comment");
:set ($container->"file") "openspeedtest.tar";
:set ($container->"remote-image") "openspeedtest/latest:latest";
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

#INTERFACE
:local interfaceList ({});
:local interface ({});

#:set ($interface->"name");
:set ($interface->"name") "-dual-stack";
:set ($interface->"mac-address");
:set ($interface->"address") "10.11.12.12/24, fd17:fa22:2edf::c/64";
:set ($interface->"gateway") 10.11.12.1;
:set ($interface->"gateway6") fd17:fa22:2edf::1;
:set ($interface->"dhcp");
:set ($interface->"bridge") $bridge;

:set interfaceList ($interfaceList, {$interface});

#MOUNTS
:local mountList ({});
:local mount ({});

:set ($mount->"name") "-nginx";
:set ($mount->"dst") "/var/log/nginx";
:set mountList ($mountList, {$mount});

#ENVIROMENT
:local enviromentList ({});
:local enviroment ({});

#:set enviroment ({"list"=""; "key"="CHANGE_CONTAINER_PORTS"; "value"="True"}); #SET container->user = root
#:set enviromentList ($enviromentList, {$enviroment});

#:set enviroment ({"list"=""; "key"="HTTP_PORT"; "value"="80"}); #SET container->user = root
#:set enviromentList ($enviromentList, {$enviroment});

#:set enviroment ({"list"=""; "key"="HTTPS_PORT"; "value"="443"}); #SET container->user = root
#:set enviromentList ($enviromentList, {$enviroment});

:set enviroment ({"list"=""; "key"="SET_SERVER_NAME"; "value"="Mikrotik Containers"});
:set enviromentList ($enviromentList, {$enviroment});

#:set enviroment ({"list"=""; "key"="ENABLE_LETSENCRYPT"; "value"="False"});
#:set enviromentList ($enviromentList, {$enviroment});

#:set enviroment ({"list"=""; "key"="DOMAIN_NAME"; "value"="speedtest.yourdomain.com"});
#:set enviromentList ($enviromentList, {$enviroment});

#:set enviroment ({"list"=""; "key"="USER_EMAIL"; "value"="you@yourdomain.com"});
#:set enviromentList ($enviromentList, {$enviroment});

#DEVICES
:local devicesList ({});

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
