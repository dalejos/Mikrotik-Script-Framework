:global telegramSendMessage;
:set telegramSendMessage do={
    :local botToken $1;
    :local isSend false;
    :local params [:toarray ""];
    :local urlParams "";
    
    :if ($2 != nil) do={:set ($params->0) "chat_id=$2";};
    :if ($3 != nil) do={:set ($params->1) "text=$3";};
    :if ($4 != nil) do={:set ($params->2) "parse_mode=$4";};
    :if ($5 != nil) do={:set ($params->3) "reply_to_message_id=$5";};
    
    :if ([:len $params] > 0) do={
        :set urlParams "\?";
        :foreach p in=$params do={
            :set urlParams "$urlParams$p&";
        }
        :set urlParams [:pick $urlParams 0 ([:len $urlParams]-1)];
    }    
    
    do {
        :local result [/tool fetch url=("https://api.telegram.org/bot" . $botToken . "/sendMessage$urlParams") output=user as-value];
        :if (($result->"status") = "finished") do={
            :set isSend (($result->"data")~"\"ok\":true");
        }
    } on-error={
        :return $isSend;
    }
    :return $isSend;
}

:global telegramGetUpdates;
:set telegramGetUpdates do={
    :local botToken $1;
    :local params [:toarray ""];
    :local urlParams "";
    
    :if ($2 != nil) do={:set ($params->0) "offset=$2";};
    :if ($3 != nil) do={:set ($params->1) "limit=$3";};
    
    :if ([:len $params] > 0) do={
        :set urlParams "\?";
        :foreach p in=$params do={
            :set urlParams "$urlParams$p&";
        }
        :set urlParams [:pick $urlParams 0 ([:len $urlParams]-1)];
    }
    
    do {
        :local result [/tool fetch url=("https://api.telegram.org/bot$botToken/getUpdates$urlParams") \
                       output=user as-value];
        :if (($result->"status") = "finished") do={
            :return ($result->"data");
        }
    } on-error={
        :return "";
    }
    :return "";
}