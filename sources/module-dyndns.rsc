#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario: 

:global setLastError;
:local lScriptName "module-dyndns";

#TODO-BEGIN

:global getFileContents;

#http://checkip.dyndns.com/

#Function resolveHost
#   Param:
#   $1: Host name
#
:global resolveHost;
:global resolveHost do={
    :local lIp;
    do {
        :set lIp [:resolve $1];
    } on-error={
        :return "0";
    }
    :return $lIp;
};

#Function getInterfaceIP
#   Param:
#   $1: Interface
#   $2: Notation CIRD
#
:global getInterfaceIP;
:global getInterfaceIP do={
    :local lIp;
    :local lCIRD;
    
    :if ([:len $2] > 0) do={
        :set lCIRD $2;
    }
    do {
        :set lIp [/ip address get [find interface=$1] address];
    } on-error={
        :return "0";
    }
    :if (!$lCIRD) do={
        :set $lIp [:pick $lIp 0 [:find $lIp "/"]];
    }
    :return $lIp;
};

#Function getIPFromExternalServer
#   Param:
#   $1: Interface
#
:global getIPFromExternalServer;
:global getIPFromExternalServer do={
}

#TODO-END

$setLastError 0 ("$lScriptName cargado.");