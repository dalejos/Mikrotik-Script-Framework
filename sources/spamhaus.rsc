#Version: 3.0 alpha.
#Fecha: 22-12-2019.
#RouterOS 6.43 y superior.
#Comentario:

#TODO-BEGIN

:local spamhausList;
:local spamhausList do={
    :local asList ({"error"=false; data=[]});
    :local url $1;
    
    do {
        :local result [/tool fetch url=$url mode=https as-value output=user];
        :local found -1;
        :local start 0;
        :local line "";
        
        :do {
            :set found [find ($result->"data") "\n" $found];
            :if ($found >= 0) do={
                :set line [pick ($result->"data") $start $found];
                :set start ($found + 1);
                :if ([pick $line 0] != ";") do={
                    :local asn [pick $line 0 [find $line " ;"]];
                    :set ($asList->"data") (($asList->"data"), asn);
                }
            }
        } while=($found >= 0);
    } on-error={
        :set ($asList->"error") true;
    }
    :return $asList;
}

:put [$spamhausList "https://www.spamhaus.org/drop/asndrop.txt"];
:put [$spamhausList "https://www.spamhaus.org/drop/drop.txt"];

#TODO-END
#(192.168.10.10&(255.255.255.255<<32-24))