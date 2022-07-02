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
:set ($container->"name") "omaga-controller";
:set ($container->"file") (($container->"name") . ".tar");
:set ($container->"remote-image") "mbentley/omada-controller:latest";
:set ($container->"address") "10.11.12.10";
:set ($container->"cmd") "";
:set ($container->"entrypoint") "";
:set ($container->"domain-name") "docker.lan";
:set ($container->"hostname") ($container->"name");
:set ($container->"logging") yes;
:set ($container->"stop-signal") "15";
:set ($container->"comment") "";
:set ($container->"dns") "";
:set ($container->"workdir") "";
:set ($container->"re-mount") true;
  
#ENVIROMENT
:local enviroment ({});
:set ($enviroment->"TZ") "America/Caracas";

#MOUNTS
:local mounts ({});
:set ($mounts->"omada-data") "/opt/tplink/EAPController/data";
:set ($mounts->"omada-work") "/opt/tplink/EAPController/work";
:set ($mounts->"omada-logs") "/opt/tplink/EAPController/logs";

#REGISTER
:set ($container->"enviroment") $enviroment;
:set ($container->"mounts") $mounts;

:global registerContainer;
[$registerContainer bridge=$bridge disk=$disk container=$container];
