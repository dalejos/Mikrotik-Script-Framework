#Version: 3.0 alpha
#Fecha: 22-03-2020
#RouterOS 6.46.4 y superior.
#Comentario: 

:global romonId;
:global romonUser;

:global setRomonTarget;
:global setRomonTarget do={
    :global romonId;
    :global romonUser;
    :if (([:len $1] > 0) or ([:len $id] > 0)) do={
        :set romonId "$1$id";
    }
    
    :if (([:len $user] > 0)) do={
        :set romonUser "$user";
    }
}

:global executeRomonCommand;

:global executeRomonCommand do={
    :global romonId;
    :global romonUser;
    /tool romon ssh address=$romonId user=$romonUser command=$romonCommand;
}

:global setRomonIdentity;

:global setRomonIdentity do={
    :global executeRomonCommand;
    :local command "/system identity set name=\"$1\"";
    :put "$command";
    $executeRomonCommand romonCommand=$command;
}

:global setInterfacePVID;

:global setInterfacePVID do={
    :global executeRomonCommand;
    :local command "/interface bridge port set [find bridge=$1 interface=$2] pvid=$3";
    $executeRomonCommand romonCommand=$command;
}

:global setInterfaceTaggetVLAN;

:global setInterfaceTaggetVLAN do={
    :global executeRomonCommand;
    :local command "{\
    :local bridgeName \"$1\";\
    :local vlanIds [:toarray \"$2\"];\
    :local interfaceNames [:toarray \"$3\"];\
    :foreach vlanId in=\$vlanIds do={\
        :put \"VLAN: \$vlanId\";\
        :local id [/interface bridge vlan find where vlan-ids~\"\$vlanId\"];\
        :if (([:len \$id] = 0)) do={\
            :local interfaceName \"\";\
            :foreach iName in=\$interfaceNames do={\
                :set interfaceName \"\$interfaceName,\$iName\";\
            };\
             /interface bridge vlan add bridge=\$bridgeName vlan-ids=\$vlanId tagged=\"\$interfaceName\";\
        } else={\
            :foreach iName in=\$interfaceNames do={\
                :local tagged [/interface bridge vlan get \$id tagged];\
                :local interfaceName \"\";\
                :foreach iTagged in=\$tagged do={\
                    :if ([:len \$interfaceName] = 0) do={\
                        :set interfaceName \"\$iTagged\";\
                    } else={\
                        :set interfaceName \"\$interfaceName,\$iTagged\";\
                    }\
                };\
                :put \"Interface: \$iName - Current: \$interfaceName\";\
                :if (!(\$interfaceName~\$iName)) do={\
                    :set interfaceName \"\$interfaceName,\$iName\";\
                    /interface bridge vlan set \$id tagged=\"\$interfaceName\";\
                }\
            };\
        }\
    };\
:put \"EXECUTE\"}";
    $executeRomonCommand romonCommand=$command;
}

{
    :local bridgeName "$1";
    :local vlanIds [:toarray "$2"];
    :local interfaceNames [:toarray "$3"];
    :foreach vlanId in=$vlanIds do={
        :local id [/interface bridge vlan find where vlan-ids~"$vlanId"];
        :if (([:len $id] = 0)) do={
            :local interfaceName "";
            :foreach iName in=$interfaceNames do={
                :set interfaceName "$interfaceName,$iName";
            };
             /interface bridge vlan add bridge=$bridgeName vlan-ids=$vlanId tagged="$interfaceName";
        } else={
            :foreach iName in=$interfaceNames do={
                :local tagged [/interface bridge vlan get $id tagged];
                :local interfaceName "";
                :foreach iTagged in=$tagged do={
                    :if ([:len $interfaceName] = 0) do={
                        :set interfaceName "$iTagged";
                    } else={
                        :set interfaceName "$interfaceName,$iTagged";
                    }
                };
                :if (!($interfaceName~$iName)) do={
                    :set interfaceName "$interfaceName,$iName";
                    /interface bridge vlan set $id tagged="$interfaceName";
                }
            };
        }
    }
}

{
    :local ethers [/interface ethernet find];
~
    :foreach ether in=$ethers do={
        :local name [/interface ethernet get $ether name];
        do {
            /interface bridge port add bridge="bridge" interface=$name pvid=10;
        } on-error={
            :put "Error al agregar interface $name";
        }
    }
}

#DHCP Script
/log info message=("Lease $leaseBound - $leaseActIP - " . $"lease-hostname");
:if ($leaseBound = 1) do={
    /ip dns static add address=$leaseActIP name=($"lease-hostname" . ".ccvc.local");
}

/interface bridge
add name=bridge pvid=100 vlan-filtering=yes
/interface bridge port
add bridge=bridge interface=ether1 pvid=10
add bridge=bridge interface=ether2 pvid=10
add bridge=bridge interface=ether3 pvid=10
add bridge=bridge interface=ether4 pvid=10
add bridge=bridge interface=ether5 pvid=10
add bridge=bridge interface=ether6 pvid=10
add bridge=bridge interface=ether7 pvid=10
add bridge=bridge interface=ether8 pvid=10
add bridge=bridge interface=ether9 pvid=10
add bridge=bridge interface=ether10 pvid=10
add bridge=bridge interface=ether11 pvid=10
add bridge=bridge interface=ether12 pvid=10
add bridge=bridge interface=ether13 pvid=10
add bridge=bridge interface=ether14 pvid=10
add bridge=bridge interface=ether15 pvid=10
add bridge=bridge interface=ether16 pvid=10
add bridge=bridge interface=ether17 pvid=10
add bridge=bridge interface=ether18 pvid=10
add bridge=bridge interface=ether19 pvid=10
add bridge=bridge interface=ether20 pvid=10
add bridge=bridge interface=ether21 pvid=10
add bridge=bridge interface=ether22 pvid=10
add bridge=bridge interface=ether23 pvid=10
add bridge=bridge interface=ether24 pvid=10
add bridge=bridge interface=ether25 pvid=10
add bridge=bridge interface=ether26 pvid=10
/interface bridge vlan
add bridge=bridge tagged=ether25,ether26 vlan-ids=100
add bridge=bridge tagged=ether25,ether26 vlan-ids=10
/ip dhcp-client
remove 0
add disabled=no interface=bridge




















