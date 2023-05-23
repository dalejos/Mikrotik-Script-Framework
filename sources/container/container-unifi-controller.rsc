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
:set ($container->"name") "unifi-controller";
:set ($container->"file") (($container->"name") . ".tar");
:set ($container->"remote-image") "linuxserver/unifi-controller:latest";
:set ($container->"address") "10.11.12.9";
:set ($container->"cmd") "";
:set ($container->"entrypoint") "";
:set ($container->"domain-name") "docker.lan";
:set ($container->"hostname") ($container->"name");
:set ($container->"logging") yes;
:set ($container->"stop-signal") "15";
:set ($container->"comment") "";
:set ($container->"dns") "";
:set ($container->"workdir") "";
:set ($container->"start-on-boot") false;

:set ($container->"nat") true;
:set ($container->"re-mount") true;

#ENVIROMENT
:local enviroment ({});
:set ($enviroment->"TZ") "America/Caracas";
:set ($enviroment->"MEM_LIMIT") "512";
:set ($enviroment->"MEM_STARTUP") "256";

#MOUNTS
:local mounts ({});
:set ($mounts->"config") "/config";

#PORTS
:local ports ({});
:set ($ports->"tcp"->"8443") "8443";
:set ($ports->"tcp"->"8080") "8080";
:set ($ports->"tcp"->"8843") "8843";
:set ($ports->"tcp"->"8880") "8880";
:set ($ports->"tcp"->"6789") "6789";

:set ($ports->"udp"->"3478") "3478";
:set ($ports->"udp"->"10001") "10001";
:set ($ports->"udp"->"1900") "1900";
:set ($ports->"udp"->"5514") "5514";

#REGISTER
:set ($container->"enviroment") $enviroment;
:set ($container->"mounts") $mounts;
:set ($container->"ports") $ports;

:global registerContainer;
[$registerContainer bridge=$bridge disk=$disk container=$container];
