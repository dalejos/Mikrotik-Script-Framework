{
    :local interfaceInfo [:toarray ""];
    
    :local bridges [/interface bridge find];
    
    :foreach id in=$bridges do={
        :local bridgeName [/interface bridge get $id name];
        :put "Bridge: $bridgeName";
        :local vlans [/interface bridge vlan find where bridge=$bridgeName];
        :foreach vid in=$vlans do={
            :local vlanId [/interface bridge vlan get $vid vlan-ids];
            :put "VLAN  : $vlanId";
            :put "";
            :local hosts [/interface bridge host find where local=yes bridge=$bridgeName vid=$vlanId];
            :foreach h in=$hosts do={
                :local i [/interface bridge host get $h];
                :put (($i->"interface") . ": " . ($i->"mac-address"));
            }
        }
    }
}

:global F [:toarray ""];

:set ($F->"f1") do={:put "$1";};

:global f1 ($F->"f1");