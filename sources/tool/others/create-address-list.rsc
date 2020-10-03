{
:local listPar "VLAN55-PAR";
:local listImpar "VLAN55-IMPAR";
:local ipPrefix "192.168.55.";

:for index from=1 to=254 do={
    if (($index % 2) = 0) do={
        /ip firewall address-list add list="$listPar" address="$ipPrefix$index";
    } else={
        /ip firewall address-list add list="$listImpar" address="$ipPrefix$index";
    }
}
}