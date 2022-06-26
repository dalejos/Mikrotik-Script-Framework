:if ([:len [/system script job find script="script-telegram-active-users"]] > 1) do={
    :return 255;
}

:global config;
:global telegramSendMessage;

:local botToken ($config->"telegram"->"botToken");
:local chatID ($config->"telegram"->"chatID");

:local addressType;
:set addressType do={
    :local ipAddress [:toip $1];
    :if ([:len $ipAddress] = 0) do={
        :return "UNKNOW";
    }
    :local isPrivate  ((10.0.0.0 = ($ipAddress&255.0.0.0)) \
                        or (172.16.0.0 = ($ipAddress&255.240.0.0)) \
                        or  (192.168.0.0 = ($ipAddress&255.255.0.0)));
    :if ($isPrivate) do={
        :return "PRIVATE";
    }
    :local isReserved ((0.0.0.0 = ($ipAddress&255.0.0.0)) \
                        or (127.0.0.0 = ($ipAddress&255.0.0.0)) \
                        or (169.254.0.0 = ($ipAddress&255.255.0.0)) \
                        or (224.0.0.0 = ($ipAddress&240.0.0.0)) \
                        or (240.0.0.0 = ($ipAddress&240.0.0.0)));
    :if ($isReserved) do={
        :return "RESERVED";
    }
    :return "PUBLIC";
}

:local identity [/system identity get name];

:foreach id in=[/user active find] do={
    :local lastIndex [:tonum ("0x" . [:pick $id 1 [:len $id]])];
    :if (($config->"telegram"->"activeUsers"->"lastUser") < $lastIndex) do={
        :set ($config->"telegram"->"activeUsers"->"lastUser") $lastIndex;
        :local userData [/user active get $id];
        :local name ($userData->"name");
        :local when ($userData->"when");
        :local address ($userData->"address");
        :local via ($userData->"via");
        :local ipType [$addressType $address];
        :if ($ipType="PUBLIC") do={
            :local lUrl "http://ip-api.com/csv/$address?fields=status,message,country,countryCode,as,asname,query";
            :local result [/tool fetch url=$lUrl mode=http as-value output=user];
            :local arrayResult [:toarray ($result->"data")];
            :if ([:typeof $arrayResult] = "array") do={
                :if ([:pick $arrayResult 0] = "success") do={
                    :set ipType "country: *$($arrayResult->2) - $($arrayResult->1)*\n\
                                 as: *$($arrayResult->3)*";
                }
            }
        }
        :set ($config->"telegram"->"activeUsers"->"messages"->"id-$lastIndex") "*Login on: $identity*\n\n\
                                           at: *$when*\n\
                                           user: *$name*\n\
                                           from: *$address*\n\
                                           via: *$via*\n\
                                           $ipType";
    }
}

:foreach id,message in=($config->"telegram"->"activeUsers"->"messages") do={
    :local send [$telegramSendMessage $botToken $chatID $message "Markdown"];    
    :if ($send) do={
        :set ($config->"telegram"->"activeUsers"->"messages"->"$id");
    }
}