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

#CONTAINER
:local container ({});
:set ($container->"name") "unifi-controller";
:set ($container->"file") "disk3/images/unifi-controller.tar";
:set ($container->"remote-image") "linuxserver/unifi-controller:latest";
:set ($container->"address") "10.11.12.9";
:set ($container->"cmd") "";
:set ($container->"entrypoint") "";
:set ($container->"domain-name") "docker.lan";
:set ($container->"hostname") ($container->"name");
:set ($container->"logging") yes;
:set ($container->"stop-signal") "";
:set ($container->"comment") "";
:set ($container->"dns") "";
:set ($container->"workdir") "";
:set ($container->"re-mount") true;

#ENVIROMENT
:local enviroment ({});

#MOUNTS
:local mounts ({});
:set ($mounts->"config") "/config";

#REGISTER
:set ($container->"enviroment") $enviroment;
:set ($container->"mounts") $mounts;

:global registerContainer;
[$registerContainer bridge=$bridge disk=$disk container=$container];
