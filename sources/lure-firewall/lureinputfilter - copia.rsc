#Esta regla debe ir luego de las reglas INPUT que si aceptas
#Procesa los INPUT desde las lita de interface WAN y que no este en la lista
#secure_list
#Agrega a la lista secure_list tu red local.


:global bu ({});
:global i 0;
:global j 0;
:do {
    :set ($bu->$i) 1024;
    :set i ($i + 1);
    :set j ($j + 1);
    :if ($j >= 1024) do={
        :put "INDEX: $i";
        :set j 0;
    }
} while=(true);


:global services;
:set services ({});

#Function registerService
#   Param:
#   $1: port
#   $2: protocol
#   $3: list
#   $4: comment

:global registerService;
:set registerService do={
    :global services;
    :local length [:len $services];
    :set ($services->$length) {"port"=$1;"protocol"=$2;"list"=$3;"comment"=$4};
}

$registerService 21 "tcp" "lure_ftp" "Ftp";
$registerService 22 "tcp" "lure_ssh" "Secure Shell";
$registerService 23 "tcp" "lure_telnet" "Telnet";

:foreach service in=$services do={
    :put $service;
}






:local chainName "lure_input";

/ip firewall filter

remove numbers=[find jump-target=$chainName];

add action=jump chain=input comment="lure input" connection-state=new \
    in-interface-list=WAN jump-target=$chainName src-address-list=\
    !secure_list


:local services;
:set services \
{\
    {\
        "port"="21";\
        "protocol"="tcp";\
        "list"="lure_ftp";\
        "comment"="Ftp"\
    };\
    {\
        "port"="22";\
        "protocol"="tcp";\
        "list"="lure_ssh";\
        "comment"="Secure Shell"\
    };\
    {\
        "port"="23";\
        "protocol"="tcp";\
        "list"="lure_telnet";\
        "comment"="Telnet"\
    };\
    {\
        "port"="53";\
        "protocol"="tcp";\
        "list"="lure_dns";\
        "comment"="Dns"\
    };\
    {\
        "port"="3389";\
        "protocol"="tcp";\
        "list"="lure_microsoft_rdp";\
        "comment"="Microsoft RDP"\
    };\
    {\
        "port"="8291";\
        "protocol"="tcp";\
        "list"="lure_mikrotik_winbox";\
        "comment"="Mikrotik Winbox"\
    };\
    {\
        "port"="8728, 8729";\
        "protocol"="tcp";\
        "list"="lure_mikrotik_api";\
        "comment"="Mikrotik Api"\
    };\
    {\
        "port"="53";\
        "protocol"="udp";\
        "list"="lure_dns";\
        "comment"="Dns"\
    };\
    {\
        "port"="2000";\
        "protocol"="udp";\
        "list"="lure_mikrotik_bandwith";\
        "comment"="Mikrotik Bandwith"\
    }\
};

remove numbers=[find chain=$chainName];

add action=tarpit chain=$chainName comment="lure input BLACKLIST TCP TARPIT" \
    protocol=tcp src-address-list=lure_input_blacklist;
    
add action=drop chain=$chainName comment="lure input BLACKLIST DROP" \
    src-address-list=lure_input_blacklist;

add action=add-src-to-address-list address-list=lure_input_blacklist \
    address-list-timeout=none-static chain=$chainName comment=\
    "lure input BLACKLIST" log=yes log-prefix="LURE DROP -> ";
    
:foreach service in=$services do={
    add action=add-src-to-address-list address-list=($service->"list") \
        address-list-timeout=none-static chain=$chainName comment=\
        ($service->"comment") dst-port=($service->"port") protocol=($service->"protocol");
}

add action=add-src-to-address-list address-list=lure_input_tcp \
    address-list-timeout=none-static chain=$chainName comment=\
    "lure input TCP" protocol=tcp;
add action=add-src-to-address-list address-list=lure_input_udp \
    address-list-timeout=none-static chain=$chainName comment=\
    "lure input UDP" protocol=udp;
