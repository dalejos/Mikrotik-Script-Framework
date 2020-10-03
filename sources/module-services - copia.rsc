:global services;
:set services ({});

#Function registerService
#   Param:
#   $1: port
#   $2: protocol
#   $3: list
#   $4: comment

:local registerService do={
    :global services;
    
    :local id "$1$2";
    :local service {"port"="$1";"protocol"="$2";"list"="$3";"comment"="$4"};
    :set ($services->($id)) $service;
}

# TCP
$registerService "21"               "tcp"   "lure_ftp"                   "Ftp";
$registerService "22"               "tcp"   "lure_ssh"                   "Secure Shell";
$registerService "23"               "tcp"   "lure_telnet"                "Telnet";
$registerService "53"               "tcp"   "lure_dns"                   "Dns";
$registerService "3389"             "tcp"   "lure_microsoft_rdp"         "Microsoft RDP";
$registerService "8291"             "tcp"   "lure_mikrotik_winbox"       "Mikrotik Winbox";
$registerService "8728,8729"        "tcp"   "lure_mikrotik_api"          "Mikrotik Api";

# UDP
$registerService "53"               "udp"   "lure_dns" "Dns";
$registerService "2000"             "udp"   "lure_mikrotik_bandwith"     "Mikrotik Bandwith";

:set ($services->"load") true;

:foreach service in=$services do={
    :put $service;
}

