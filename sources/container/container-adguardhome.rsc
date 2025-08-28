#BRIDGE
:local bridge ({});
:set ($bridge->"name") "docker";

:local ipv4 ({});
:set ($ipv4->"address") "10.11.12.1";
:set ($ipv4->"cidr") "24";
:set ($ipv4->"nat") true;

:local ipv6 ({});
:set ($ipv6->"address") "fd17:fa22:2edf::1";
:set ($ipv6->"cidr") "64";

:set ($bridge->"ipv4") $ipv4;
:set ($bridge->"ipv6") $ipv6;


#DISK
:local disk ({});
:set ($disk->"label") "docker";
:set ($disk->"name") "";
:set ($disk->"install-dir") "docker";
:set ($disk->"image-dir") "images";

#CONTAINER
:local container ({});
:set ($container->"name") "adguardhome";
:set ($container->"file") "adguardhome.tar";
:set ($container->"remote-image") "adguard/adguardhome:latest";
:set ($container->"address") "10.11.12.11, fd17:fa22:2edf::2";
:set ($container->"cmd") "";
:set ($container->"entrypoint") "";
:set ($container->"domain-name") "docker.lan";
:set ($container->"hostname") ($container->"name");
:set ($container->"logging") yes;
:set ($container->"stop-signal") "15";
:set ($container->"comment") ($container->"name");
:set ($container->"dns") "";
:set ($container->"workdir") "";

:set ($container->"check-certificate") no;
:set ($container->"devices") ({});
:set ($container->"memory-high") "unlimited";
:set ($container->"user") "";
:set ($container->"auto-restart-interval") "none";

:set ($container->"start-on-boot") false;

:set ($container->"nat") true;
:set ($container->"re-mount") true;

#ENVIROMENT
:local enviroment ({});

#MOUNTS
:local mounts ({});
:set ($mounts->"conf") "/opt/adguardhome/conf";
:set ($mounts->"work") "/opt/adguardhome/work";

#PORTS
:local ports ({});

#REGISTER
:set ($container->"enviroment") $enviroment;
:set ($container->"mounts") $mounts;
:set ($container->"ports") $ports;

:global registerContainer;
[$registerContainer bridge=$bridge disk=$disk container=$container];
