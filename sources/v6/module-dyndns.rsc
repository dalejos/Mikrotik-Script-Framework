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
#   $1: domain-name
#   $2: server
#   $3: server-port
#
:global resolveHost;
:global resolveHost do={
    :local domainName "domain-name=.";
    :local dnsServer "";
    :local serverPort "";
    
    :if ([:len $1] > 0) do={
        :set domainName "domain-name=$1";
        :if ([:len $2] > 0) do={
            :set dnsServer " server=$2";
            :if ([:len $3] > 0) do={
                :set serverPort " server-port=$3";
            }
        }
    }
    
    :local command [:parse "[:resolve $domainName$dnsServer$serverPort]"];
    :local ip;
    
    do {
        :set ip [$command];
    } on-error={
        :return "0";
    }
    :return [:toip $ip];
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
	:local onError true;
	:local result;

	:while ($onError) do={
		do {
			:set result [/tool fetch url=http://checkip.dyndns.org/ as-value output=user];
			:set onError false;
		} on-error={
		}
	}
	:local data ($result->"data");
	:return [:pick $data ([:find $data "Current IP Address: " -1] + 20) [:find $data "</body>" -1]];
}

#Function resolvePublicIP
#   Param:
#   $1: Interface
#
#   Resolver ip publica consultando OpenDNS
:global resolvePublicIP;
:global resolvePublicIP do={
    :global resolveHost;
    
    :local listName "RESOLVERS-OPENDNS";
    :local servers [/ip firewall address-list find list=$listName];
    :local ip "0";
     
    :foreach server in=$servers do={
        :local ipServer [:toip [/ip firewall address-list get $server address]];
        :set ip [$resolveHost "myip.opendns.com" $ipServer];
        :if ($ip != "0") do={
            :return [:toip $ip];
        }
    }
    #:return [:toip [:resolve myip.opendns.com server=208.67.222.222]]
}

#TODO-END

$setLastError 0 ("$lScriptName cargado.");