:global romons;

:set romons \
{\
    "CC:54:00:00:00:02"=\
    {\
        "interface"=\
        {\
            "bridges"=\
            {\
                "bridge"=\
                {\
                    "pvid"="100";\
                    "port"=\
                    {\
                        {\
                            "ports"="ether1,ether2,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10,ether11,ether12\
                                    ether13,ether14,ether15,ether16,ether17,ether18,ether19,ether20,ether21,ether22,ether23,ether24\
                                    ether25,ether26,ether27,ether28,ether29,ether30,ether31,ether32,ether33,ether34,ether35,ether36\
                                    ether37,ether38,ether39,ether40,ether41,ether42,ether43,ether44,ether45,ether46,\
                                    ether49,ether50,ether51,ether52,ether53,ether54,bonding-lan";\
                            "pvid"="10"\
                        }\
                    };\
                    "vlan"=\
                    {\
                        "10,20,30,40,50,100"=\
                        {\
                            "tagged"="ether49,ether50,ether51,ether52"\
                        }\
                    }\
                }\
            }\
        }\
    }\
};

:put $romons;

:set romons {"CC:54:00:00:00:02"={"interface"={"bridges"={"bridge"={"pvid"="100";"ports"={"pvids"={"10"="ether1"}};"vlans"={"10,20,30,40,50,100"={"tagged"="ether49,ether50,ether51,ether52"}}}}}}};
:put $romons;

:foreach id,value in=$romons do={
    :put $id;
    :local bridges ($value->"interface"->"bridges");
    :foreach bridgeName,bridgeValue in=$bridges do={
        :put "bridgeName: $bridgeName";
        :put ("pvid: " . ($bridgeValue->"pvid"));
        :put ($bridgeValue->"ports"->"pvids");
    };
};

                        "ether1,ether2,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10,ether11,ether12\
                        ether13,ether14,ether15,ether16,ether17,ether18,ether19,ether20,ether21,ether22,ether23,ether24\
                        ether25,ether26,ether27,ether28,ether29,ether30,ether31,ether32,ether33,ether34,ether35,ether36\
                        ether37,ether38,ether39,ether40,ether41,ether42,ether43,ether44,ether45,ether46,\
                        ether49,ether50,ether51,ether52,ether53,ether54,bonding-lan"=\


                            "10"="ether1,ether2,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10,ether11,ether12\
                                  ether13,ether14,ether15,ether16,ether17,ether18,ether19,ether20,ether21,ether22,ether23,ether24\
                                  ether25,ether26,ether27,ether28,ether29,ether30,ether31,ether32,ether33,ether34,ether35,ether36\
                                  ether37,ether38,ether39,ether40,ether41,ether42,ether43,ether44,ether45,ether46,\
                                  ether49,ether50,ether51,ether52,ether53,ether54,bonding-lan";\

/tool fetch url="https://api.telegram.org/bot1200682853:AAGs_3qqqaFZhz43Kk69X_DSesk-pvVARDs/sendMessage\?chat_id=617220857&text=Mikrotik test message" keep-result=no

:set gModules \
{\
    "01"=\
    {\
        "name"="module-functions";\
        "enable"=true;\
        "loaded"=false;\
        "config"=false;\
        "description"="Funciones Generales."\
    };\
    "02"=\
    {\
        "name"="module-dyndns";\
        "enable"=false;\
        "loaded"=false;\
        "config"=true;\
        "description"="DynDNS Update."\
    };\
    "03"=\
    {\
        "name"="module-pcc-init";\
        "enable"=false;\
        "loaded"=false;\
        "config"=true;\
        "description"="Inicializacion de modulo de balanceo por PCC."\
    };\
    "04"=\
    {\
        "name"="module-geoip";\
        "enable"=true;\
        "loaded"=false;\
        "config"=false;\
        "description"="Herramienta para localizar IP geograficamente."\
    };\
    "05"=\
    {\
        "name"="module-arrays";\
        "enable"=true;\
        "loaded"=false;\
        "config"=false;\
        "description"="Funciones para manejo de arreglos."\
    };\
    "06"=\
    {\
        "name"="module-hex";\
        "enable"=true;\
        "loaded"=false;\
        "config"=false;\
        "description"="Funciones manejo de hexadecimal."\
    };\
    "07"=\
    {\
        "name"="module-base32";\
        "enable"=true;\
        "loaded"=false;\
        "config"=false;\
        "description"="Funciones Base32."\
    };\    
    "08"=\
    {\
        "name"="module-sha1";\
        "enable"=true;\
        "loaded"=false;\
        "config"=false;\
        "description"="Funciones sha1 digest."\
    };\
    "09"=\
    {\
        "name"="module-hmac";\
        "enable"=true;\
        "loaded"=false;\
        "config"=false;\
        "description"="Funciones hmac."\
    };\
    "10"=\
    {\
        "name"="module-time";\
        "enable"=true;\
        "loaded"=false;\
        "config"=false;\
        "description"="Funciones timestamp."\
    };\
    "11"=\
    {\
        "name"="module-totp";\
        "enable"=true;\
        "loaded"=false;\
        "config"=false;\
        "description"="Funciones TOTP."\
    }\
}

:global gScripts;
:set gScripts \
{\
    "init"=\
    {\
        "startRun"=0;\
        "endRun"=0;\
        "enable"=true;\
        "startDate"="";\
        "startTime"="startup";\
        "interval"=0m;\
        "description"="Inicializacion del MSF."\
    };\
    "script-pcc-qos-wan"=\
    {\
        "startRun"=0;\
        "endRun"=0;\
        "enable"=true;\
        "startDate"="";\
        "startTime"="startup";\
        "interval"=10m;\
        "description"="PCC QoS para interfaces WAN."\
    };\
    "script-dyndns"=\
    {\
        "startRun"=0;\
        "endRun"=0;\
        "enable"=true;\
        "startDate"="";\
        "startTime"="startup";\
        "interval"=5m;\
        "description"="Dyndns Update."\
    }\
}

#TODO-END

$setLastError 0 ("$lScriptName cargado.");