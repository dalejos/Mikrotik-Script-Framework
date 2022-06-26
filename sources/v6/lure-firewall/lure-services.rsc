:global services;
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