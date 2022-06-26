:global pingLatency;
:set pingLatency do={
    
}



:global dhcpLeases;
if ([:typeof $dhcpLeases] != "array") do={
    :set $dhcpLeases [:toarray ""];
}
:global getCurrentTimestamp;
:global dhcpLeaseConfig;

:local net 0.0.0.0/0;
:local filterMAC [:toarray ""];

:if ($dhcpLeaseConfig~"net") do={
    :set net ($dhcpLeaseConfig->"net");
}

:if ($dhcpLeaseConfig~"filterMAC") do={
    :set filterMAC ($dhcpLeaseConfig->"filterMAC");
}

:if (($leaseActIP in $net) && (!($filterMAC~$leaseActMAC))) do={
    :local lease;
    :if ($leaseBound = 1) do={
        :local leaseId [/ip dhcp-server lease find where active-mac-address=$leaseActMAC];
        :local leaseInfo [/ip dhcp-server lease get $leaseId];
        :if ($leaseInfo->"dynamic") do={
            :local rawLocked [/ip firewall raw find where comment~"^$leaseActMAC"];
            :if ([:len $rawLocked] = 0) do={
                :if ([:len ($dhcpLeases->$leaseActMAC)] = 0) do={
                    :local timestamp [$getCurrentTimestamp];
                    :set lease {"hostname"=($"lease-hostname"); "bound"=true; "boundTime"=$timestamp; "checkTime"=$timestamp; "uptime"=0};
                } else={
                    :set lease ($dhcpLeases->$leaseActMAC);
                    :set ($lease->"bound") true;
                }
                :set ($dhcpLeases->$leaseActMAC) $lease;
            } else={
                /ip dhcp-server lease remove $leaseId;
            }
        }
    } else={
        :if ([:len ($dhcpLeases->$leaseActMAC)] > 0) do={
            :set lease ($dhcpLeases->$leaseActMAC);
            :set ($lease->"bound") false;
            :set ($dhcpLeases->$leaseActMAC) $lease;
        }
    }
}