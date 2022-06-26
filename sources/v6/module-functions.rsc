#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario: Funciones de uso general en MSF.

:global setLastError;
:local lScriptName "module-functions";

#TODO-BEGIN

:global NOTHING;

#Function getFileContents
#   Param:
#   $1: File name.
#
:global getFileContents;
:global getFileContents do={
    :local lContents;
    
    do {
        :set lContents [/file get [find name=$1] contents];
    } on-error={
        :return $NOTHING;
    }
    :return $lContents;
}

#Function getNetAddress
#   Param:
#   $1: CIRD address.
#
:global getNetAddress;
:global getNetAddress do={

    :local vAddress $1;
    :local vShift 0;
    :local vAddressLen ([:len $vAddress]);
    :local vIP 0.0.0.0;
    :local vNetAddress 0.0.0.0;
    :local lLocateSlash [:find $vAddress "/"];
    
    :put "lLocateSlash: $lLocateSlash";
    
    :set vIP [:pick $vAddress 0 $lLocateSlash];
    :put "vIP: $vIP";
    
    :set vShift [:pick $vAddress ($lLocateSlash + 1) $vAddressLen];
    :put "vShift: $vShift";

    :for i from=( $vAddressLen - 1) to=0 do={ 
        :if ( [:pick $vAddress $i] = "/") do={ 
            :set vIP [:pick $vAddress 0 $i];
            :set vShift ( [:tonum [:pick $vAddress ($i + 1) ($vAddressLen)]] );
        }
    }
    :set vNetAddress ($vIP & (255.255.255.255 ^ (255.255.255.255 >> $vShift)));
    :return "$vNetAddress/$vShift";
}

#Function isScriptRuning
#   Param:
#   $1: Nombre del script.
#
:global isScriptRuning;
:global isScriptRuning do={
    :local lIsRuning ([:len [/system script job find script=$1]] > 1);
    :return $lIsRuning;
}

#Function createFirewallAddressList
#   Param:
#   $1: Nombre de la lista.
#   $1: Lista de urls.
#
:global createFirewallAddressList;
:global createFirewallAddressList do={
    
    :local vListName $1;
    
    :local vDomainList $2;

    :local vDnsCache [/ip dns cache find];

    :foreach fDns in=$vDnsCache do={
        :local vDnsName [/ip dns cache get $fDns name];
        
        :foreach fDomain in=$vDomainList do={
            :if (([:len $fDomain] > 0)) do={
                :if (([:find $vDnsName $fDomain] >= 0)) do={
                    :local vDnsAddress [/ip dns cache get $fDns address];
                    :local vDnsType [/ip dns cache all get $fDns type];
                    
                    :if ($vDnsType = "A") do={            
                        :if (([:len [/ip firewall address-list find list=$vListName address=$vDnsAddress]] = 0)) do={
                            /ip firewall address-list add address=$vDnsAddress list=$vListName comment=$vDnsName;
                            :log info "Add address: $vDnsName, IP: $vDnsAddress, list: $vListName";
                        }
                    }
                }
            }
        }
    }
}

#TODO-END

$setLastError 0 ("$lScriptName cargado.");