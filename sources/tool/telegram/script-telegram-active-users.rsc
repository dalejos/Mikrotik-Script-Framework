:if ([:len [/system script job find script="script-telegram-active-users"]] > 1) do={
    :return 255;
}

:global lastUser;
:global messages;
:global telegramSendMessage;
:global telegramBotToken;
:global telegramChatID;

:local addressType;
:set addressType do={
    :local ipAddress [:toip $1];
    :if ([:len $ipAddress] = 0) do={
        :return "UNKNOW";
    }
    :local isPrivate  ((10.0.0.0 = ($ipAddress&255.0.0.0)) or (172.16.0.0 = ($ipAddress&255.240.0.0)) or  (192.168.0.0 = ($ipAddress&255.255.0.0)));
    :if ($isPrivate) do={
        :return "PRIVATE";
    }
    :local isReserved ((0.0.0.0 = ($ipAddress&255.0.0.0)) or (127.0.0.0 = ($ipAddress&255.0.0.0)) or (169.254.0.0 = ($ipAddress&255.255.0.0)) \
        or (224.0.0.0 = ($ipAddress&240.0.0.0)) or (240.0.0.0 = ($ipAddress&240.0.0.0)));
    :if ($isReserved) do={
        :return "RESERVED";
    }
    :return "PUBLIC";
}

:local identity [/system identity get name];

:foreach id in=[/user active find] do={
    :local lastIndex [:tonum ("0x" . [:pick $id 1 [:len $id]])];
    :if ($lastUser < $lastIndex) do={
        :set lastUser $lastIndex;
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
                    :set ipType "country: *$($arrayResult->2) - $($arrayResult->1)*%0A\
                                 as: *$($arrayResult->3)*";
                }
            }
        }
        :set ($messages->"id-$lastIndex") "*$identity*%0A\
                                           at: *$when*%0A\
                                           user: *$name*%0A\
                                           from: *$address*%0A\
                                           via: *$via*%0A\
                                           $ipType";
    }
}

:foreach id,message in=$messages do={
    :local send [$telegramSendMessage $telegramBotToken $telegramChatID $message];
    
    :if ($send) do={
        :set ($messages->"$id");
    }
}