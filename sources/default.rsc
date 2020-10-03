#| Switch mode:
#|  * all interfaces switched;
#| LAN Configuration:

:global defconfMode;
:log info "Starting defconf script";
#-------------------------------------------------------------------------------
# Apply configuration.
# these commands are executed after installation or configuration reset
#-------------------------------------------------------------------------------
:if ($action = "apply") do={
  # wait for interfaces
  :local count 0;
  :while ([/interface ethernet find] = "") do={
    :if ($count = 30) do={
      :log warning "DefConf: Unable to find ethernet interfaces";
      /quit;
    }
    :delay 1s; :set count ($count +1); 
  };
 /interface bridge
   add name=bridge disabled=no auto-mac=yes protocol-mode=rstp comment=defconf;
 :local bMACIsSet 0;
 :foreach k in=[/interface find where !(slave=yes  || name~"bridge")] do={
   :local tmpPortName [/interface get $k name];
   :if ($bMACIsSet = 0) do={
     :if ([/interface get $k type] = "ether") do={
       /interface bridge set "bridge" auto-mac=no admin-mac=[/interface ethernet get $tmpPortName mac-address];
       :set bMACIsSet 1;
     }
   }
   /interface bridge port
     add bridge=bridge interface=$tmpPortName comment=defconf;
 }
  /ip address add address=192.168.88.1/24 interface=bridge comment="defconf";
}
#-------------------------------------------------------------------------------
# Revert configuration.
# these commands are executed if user requests to remove default configuration
#-------------------------------------------------------------------------------
:if ($action = "revert") do={
/user set admin password=""
 /system routerboard mode-button set enabled=no
 /system routerboard mode-button set on-event=""
 /system script remove [find comment~"defconf"]
 /ip firewall filter remove [find comment~"defconf"]
 /ip firewall nat remove [find comment~"defconf"]
 /interface list member remove [find comment~"defconf"]
 /interface detect-internet set detect-interface-list=none
 /interface detect-internet set lan-interface-list=none
 /interface detect-internet set wan-interface-list=none
 /interface detect-internet set internet-interface-list=none
 /interface list remove [find comment~"defconf"]
 /tool mac-server set allowed-interface-list=all
 /tool mac-server mac-winbox set allowed-interface-list=all
 /ip neighbor discovery-settings set discover-interface-list=!dynamic
   :local o [/ip dhcp-server network find comment="defconf"]
   :if ([:len $o] != 0) do={ /ip dhcp-server network remove $o }
   :local o [/ip dhcp-server find name="defconf" !disabled]
   :if ([:len $o] != 0) do={ /ip dhcp-server remove $o }
   /ip pool {
     :local o [find name="default-dhcp" ranges=192.168.88.10-192.168.88.254]
     :if ([:len $o] != 0) do={ remove $o }
   }
   :local o [/ip dhcp-client find comment="defconf"]
   :if ([:len $o] != 0) do={ /ip dhcp-client remove $o }
 /ip dns {
   set allow-remote-requests=no
   :local o [static find comment="defconf"]
   :if ([:len $o] != 0) do={ static remove $o }
 }
 /ip address {
   :local o [find comment="defconf"]
   :if ([:len $o] != 0) do={ remove $o }
 }
 :foreach iface in=[/interface ethernet find] do={
   /interface ethernet set $iface name=[get $iface default-name]
 }
 /interface bridge port remove [find comment="defconf"]
 /interface bridge remove [find comment="defconf"]
 /interface wireless cap set enabled=no interfaces="" caps-man-addresses=""
  /caps-man manager set enabled=no
  /caps-man manager interface remove [find comment="defconf"]
  /caps-man manager interface set [ find default=yes ] forbid=no
  /caps-man provisioning remove [find comment="defconf"]
  /caps-man configuration remove [find comment="defconf"]
}
:log info Defconf_script_finished;
:set defconfMode;




-------------------------------------------------------------------------------
#| Switch mode:

#|  * all interfaces switched;

#| LAN Configuration:



:global defconfMode;

:log info "Starting defconf script";

#-------------------------------------------------------------------------------

# Apply configuration.

# these commands are executed after installation or configuration reset

#-------------------------------------------------------------------------------

:if ($action = "apply") do={

  # wait for interfaces
                              
  :local count 0;

  :while ([/interface ethernet find] = "") do={

    :if ($count = 30) do={

      :log warning "DefConf: Unable to find ethernet interfaces";

      /quit;

    }

    :delay 1s; :set count ($count +1); 

  };

 /interface bridge

   add name=bridge disabled=no auto-mac=yes protocol-mode=rstp comment=defconf;

 :local bMACIsSet 0;

 :foreach k in=[/interface find where !(slave=yes  || name~"bridge")] do={

   :local tmpPortName [/interface get $k name];

   :if ($bMACIsSet = 0) do={

     :if ([/interface get $k type] = "ether") do={

       /interface bridge set "bridge" auto-mac=no admin-mac=[/interface ethernet g
et $tmpPortName mac-address];

       :set bMACIsSet 1;

     }

   }

   /interface bridge port

     add bridge=bridge interface=$tmpPortName comment=defconf;

 }

  /ip address add address=192.168.88.1/24 interface=bridge comment="defconf";
                              
}

#-------------------------------------------------------------------------------

# Revert configuration.

# these commands are executed if user requests to remove default configuration

#-------------------------------------------------------------------------------

:if ($action = "revert") do={

/user set admin password=""

 /system routerboard mode-button set enabled=no

 /system routerboard mode-button set on-event=""

 /system script remove [find comment~"defconf"]

 /ip firewall filter remove [find comment~"defconf"]

 /ip firewall nat remove [find comment~"defconf"]
 /interface list member remove [find comment~"defconf"]

 /interface detect-internet set detect-interface-list=none

 /interface detect-internet set lan-interface-list=none

 /interface detect-internet set wan-interface-list=none

 /interface detect-internet set internet-interface-list=none

 /interface list remove [find comment~"defconf"]

 /tool mac-server set allowed-interface-list=all

 /tool mac-server mac-winbox set allowed-interface-list=all

 /ip neighbor discovery-settings set discover-interface-list=!dynamic

   :local o [/ip dhcp-server network find comment="defconf"]

   :if ([:len $o] != 0) do={ /ip dhcp-server network remove $o }

   :local o [/ip dhcp-server find name="defconf" !disabled]

   :if ([:len $o] != 0) do={ /ip dhcp-server remove $o }

   /ip pool {

     :local o [find name="default-dhcp" ranges=192.168.88.10-192.168.88.254]

     :if ([:len $o] != 0) do={ remove $o }

   }

   :local o [/ip dhcp-client find comment="defconf"]

   :if ([:len $o] != 0) do={ /ip dhcp-client remove $o }

 /ip dns {

   set allow-remote-requests=no
   :local o [static find comment="defconf"]

   :if ([:len $o] != 0) do={ static remove $o }

 }                            

 /ip address {

   :local o [find comment="defconf"]

   :if ([:len $o] != 0) do={ remove $o }

 }

 :foreach iface in=[/interface ethernet find] do={

   /interface ethernet set $iface name=[get $iface default-name]

 }

 /interface bridge port remove [find comment="defconf"]

 /interface bridge remove [find comment="defconf"]

 /interface wireless cap set enabled=no interfaces="" caps-man-addresses=""

  /caps-man manager set enabled=no
                              
  /caps-man manager interface remove [find comment="defconf"]

  /caps-man manager interface set [ find default=yes ] forbid=no

  /caps-man provisioning remove [find comment="defconf"]

  /caps-man configuration remove [find comment="defconf"]

}

:log info Defconf_script_finished;

:set defconfMode;

