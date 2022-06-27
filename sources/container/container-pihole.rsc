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
:set ($container->"name") "pihole";
:set ($container->"file") (($container->"name") . ".tar");
:set ($container->"remote-image") "pihole/pihole:latest";
:set ($container->"address") "10.11.12.2";
:set ($container->"cmd") "";
:set ($container->"entrypoint") "";
:set ($container->"domain-name") "docker.lan";
:set ($container->"hostname") ($container->"name");
:set ($container->"logging") yes;
:set ($container->"stop-signal") "";
:set ($container->"comment") ($container->"name");
:set ($container->"dns") "";
:set ($container->"workdir") "";
:set ($container->"re-mount") true;

#ENVIROMENT
:local enviroment ({});
:set ($enviroment->"TZ") "America/Caracas";
:set ($enviroment->"WEBPASSWORD") "123456";
:set ($enviroment->"DNSMASQ_USER") "root";

#MOUNTS
:local mounts ({});
:set ($mounts->"etc") "/etc/pihole";
:set ($mounts->"etc-dnsmasq.d") "/etc/dnsmasq.d";

#REGISTER
:set ($container->"enviroment") $enviroment;
:set ($container->"mounts") $mounts;

:global registerContainer;
[$registerContainer bridge=$bridge disk=$disk container=$container];
