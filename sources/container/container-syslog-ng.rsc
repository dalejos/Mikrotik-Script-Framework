#ALPINE install libdbi-drivers (apk add libdbi-drivers)

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
:set ($container->"name") "syslog-ng";
:set ($container->"file") (($container->"name") . ".tar");
:set ($container->"remote-image") "linuxserver/syslog-ng:latest";
:set ($container->"address") "10.11.12.5";
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

#MOUNTS
:local mounts ({});
:set ($mounts->"config") "/config";
:set ($mounts->"log") "/var/log";

#PORTS
:local ports ({});

#REGISTER
:set ($container->"enviroment") $enviroment;
:set ($container->"mounts") $mounts;
:set ($container->"ports") $ports;

:global registerContainer;
[$registerContainer bridge=$bridge disk=$disk container=$container];
