#Esta regla debe ir luego de las reglas INPUT que se aceptan
#Procesa los INPUT desde las lita de interface WAN y que no este en la lista
#secure_list
#Agrega a la lista secure_list tu red local.

:global services;
:if ([:len $services] <= 0) do={
    /system script run lure-services
}

:local chainName "lure_input";

/ip firewall filter

:local jumpId [find jump-target=$chainName];

:if ([:len $jumpId] <= 0) do={
    add action=jump chain=input comment="lure input" connection-state=new \
        in-interface-list=WAN jump-target=$chainName src-address-list=\
        !secure_list
}

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
