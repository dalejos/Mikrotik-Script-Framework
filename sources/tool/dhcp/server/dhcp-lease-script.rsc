:global dhcpLeases;
if ([:typeof $dhcpLeases] != "array") do={
    :set $dhcpLeases [:toarray ""];
}
:global getCurrentTimestamp;
:global format;
:global dhcpLeaseConfig;

:local dhcpServer "";
:local dhcpLeaseTime 10m;
:local unlockedTime (60 * 60);
:local lockedTime (60 * 30);

:if ($dhcpLeaseConfig~"dhcpServer") do={
    :set dhcpServer ($dhcpLeaseConfig->"dhcpServer");
}

:if ($dhcpLeaseConfig~"dhcpLeaseTime") do={
    :set dhcpLeaseTime ($dhcpLeaseConfig->"dhcpLeaseTime");
}

:if ($dhcpLeaseConfig~"unlockedTime") do={
    :set unlockedTime ($dhcpLeaseConfig->"unlockedTime");
}

:if ($dhcpLeaseConfig~"lockedTime") do={
    :set lockedTime ($dhcpLeaseConfig->"lockedTime");
}

:local dhcpServerId [/ip dhcp-server find where name=$dhcpServer];
:if ([:len $dhcpServerId] > 0) do={
    :local defaultLeaseTime [/ip dhcp-server get $dhcpServerId lease-time];
    :if ($defaultLeaseTime < dhcpLeaseTime) do={
        :set dhcpLeaseTime $defaultLeaseTime;
    }
}
:local dhcpLastSeen (($dhcpLeaseTime / 2) + 15s);
:local timestamp [$getCurrentTimestamp];

:put "";
:put "";
:put "dhcpServer: $dhcpServer";
:put "dhcpLeaseTime: $dhcpLeaseTime";
:put "dhcpLastSeen: $dhcpLastSeen";
:put "timestamp: $timestamp";
:put "unlockedTime: $unlockedTime";
:put "lockedTime: $lockedTime";

:put "";
:put ([$format " MAC-ADDRESS" 20] . [$format "IP" 16] . [$format "HOST NAME" 21] . [$format "BOUND" 7] . [$format "LAST-SEEN" 11] \
 . [$format "BOUND TIME" 16] . [$format "CHECK TIME" 16] . [$format "UPTIME" 16]);

:foreach mac,lease in=$dhcpLeases do={

    :local leaseId [/ip dhcp-server lease find where active-mac-address=$mac];
    :local leaseInfo [:toarray ""];
    if ([:len $leaseId] > 0) do={
        :set leaseInfo [/ip dhcp-server lease get $leaseId];
    }
    if (($lease->"bound") = true) do={
        if ([:len $leaseInfo] > 0) do={
            
            :if (($leaseInfo->"last-seen") < $dhcpLastSeen) do={
                :set ($lease->"uptime") (($timestamp - ($lease->"checkTime")) + ($lease->"uptime"));
            } else={
                if ([/ping ($leaseInfo->"active-address") count=3] > 0) do={
                    :set ($lease->"uptime") (($timestamp - ($lease->"checkTime")) + ($lease->"uptime"));
                    :set ($dhcpLeases->$mac) $lease;
                }
            }
            
            :if (($lease->"uptime") >= $unlockedTime) do={
                /ip firewall raw add chain="prerouting" src-mac-address=$mac action="drop" comment=("$mac-" . ($timestamp + $lockedTime));
                :set ($dhcpLeases->$mac);
                /ip dhcp-server lease remove $leaseId;
            }                        
        }
    }
    
    :set ($lease->"checkTime") $timestamp;
    :put ([$format (" $mac") 20] . [$format ($leaseInfo->"active-address") 16] . [$format ($lease->"hostname") 21] . [$format ($lease->"bound") 7] . [$format ($leaseInfo->"last-seen") 11] \
    . [$format ($lease->"boundTime") 16] . [$format ($lease->"checkTime") 16] . [$format [:totime (($lease->"uptime") . "s")] 16]);    
}

:put "";
:put ([$format " MAC-ADDRESS" 20] . [$format "LOCKED TIME" 16] . [$format "TIME TO UNLOCK" 16]);
 
:local rawLockeds [/ip firewall raw find where comment~"^[0-9A-F][0-9A-F]:"];
:foreach rawId in=$rawLockeds do={
    :local itemRaw [/ip firewall raw get $rawId];
    :local mac ($itemRaw->"src-mac-address");
    :local downtime [:tonum [:pick ($itemRaw->"comment") 18 [:len ($itemRaw->"comment")]]];
    :put ([$format (" $mac") 20] . [$format $downtime 16] . [$format [:totime (($downtime - $timestamp) . "s")] 16]);
    :if ($timestamp > $downtime) do={
        /ip firewall raw remove $rawId;
    }
}