#IP Services

:local services {\
    "api"={\
        "disabled"=true;\
        "port"=8728;\
        "address"="";\
        "certificate"="none"};\
    "api-ssl"={\
        "disabled"=true;\
        "port"=8729;\
        "address"="";\
        "certificate"="none"};\
    "ftp"={\
        "disabled"=true;\
        "port"=21;\
        "address"="";\
        "certificate"="none"};\
    "ssh"={\
        "disabled"=true;\
        "port"=22;\
        "address"="";\
        "certificate"="none"};\
    "telnet"={\
        "disabled"=true;\
        "port"=23;\
        "address"="";\
        "certificate"="none"};\
    "winbox"={\
        "disabled"=false;\
        "port"=8291;\
        "address"="";\
        "certificate"="none"};\
    "www"={\
        "disabled"=true;\
        "port"=80;\
        "address"="";\
        "certificate"="none"};\
    "www-ssl"={\
        "disabled"=true;\
        "port"=443;\
        "address"="";\
        "certificate"="none"}\
};

:foreach service,properties in=$services do={
    :put "name: $service";
    :put "disabled: $($properties->"disabled")";
    :put "port: $($properties->"port")";
    :put "address: $($properties->"address")";
    :put "certificate: $($properties->"certificate")";
    :put "";
    /ip service set $service disabled=($properties->"disabled") port=($properties->"port") address=($properties->"address") certificate=($properties->"certificate");
}

#IP Neighbor
:local neighborInterfaceList "none";
/ip neighbor discovery-settings set discover-interface-list=$neighborInterfaceList;

#IP Proxy
:local proxyEnabled false;
/ip proxy set enabled=$proxyEnabled;

#IP Socks
:local socksEnabled false;
/ip socks set enabled=$socksEnabled;

#IP Upnp
:local upnpEnabled false;
/ip upnp set enabled=$upnpEnabled;

#IP Cloud
:local ddnsEnabled false;
:local updateTime false;
/ip cloud set ddns-enabled=$ddnsEnabled update-time=$updateTime;

#IP SMB
:local smbEnabled false;
/ip smb set enabled=$smbEnabled;

#IP SSH
:if (!($services->"ssh"->"disabled")) do={
    :local strongCrypto true;
    /ip ssh set strong-crypto=$strongCrypto;
}


#Tool Romon
:local enabledRomon false;
/tool romon set enabled=$enabledRomon;

#Mac Server
:local macServerInterfaceList "none";
:local macWinboxInterfaceList "none";
:local macPingEnabled false;
/tool mac-server set allowed-interface-list=$macServerInterfaceList;
/tool mac-server mac-winbox set allowed-interface-list=$macWinboxInterfaceList;
/tool mac-server ping set enabled=$macPingEnabled;

#Bandwidth Server
:local bandwidthServerEnabled false;
/tool bandwidth-server set enabled=$bandwidthServerEnabled;

#DNS Server
:local allowRemoteRequests true;
/ip dns set allow-remote-requests=$allowRemoteRequests;

