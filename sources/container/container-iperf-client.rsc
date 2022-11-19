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
:set ($container->"name") "iperf3-alpine-client";
:set ($container->"file") "iperf3-alpine.tar";
:set ($container->"remote-image") "taoyou/iperf3-alpine:latest";
:set ($container->"address") "10.11.12.4";
:set ($container->"cmd") "/bin/sh";
:set ($container->"entrypoint") "iperf3 -c 10.11.12.3 -P 2 -t 120 -l 256K";
:set ($container->"domain-name") "docker.lan";
:set ($container->"hostname") ($container->"name");
:set ($container->"logging") yes;
:set ($container->"stop-signal") "15";
:set ($container->"comment") ($container->"name");
:set ($container->"dns") "";
:set ($container->"workdir") "";
:set ($container->"start-on-boot") false;

:set ($container->"re-mount") true;

#ENVIROMENT
:local enviroment ({});

#MOUNTS
:local mounts ({});

#REGISTER
:set ($container->"enviroment") $enviroment;
:set ($container->"mounts") $mounts;

:global registerContainer;
[$registerContainer bridge=$bridge disk=$disk container=$container];
