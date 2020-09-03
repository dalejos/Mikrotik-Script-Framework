:global encodeUrl;
:set encodeUrl do={
    :local url $1;
    :local safe "";
    :local safeChar {" "="%20"; \
                     "!"="%21"; \
                     "#"="%23"; \
                     "%"="%25"; \
                     "&"="%26"; \
                     "'"="%27"; \
                     "("="%28"; \
                     ")"="%29"; \
                     "*"="%2A"; \
                     "+"="%2B"; \
                     ","="%2C"; \
                     "-"="%2D"; \
                     "."="%2E"; \
                     "/"="%2F"; \
                     ":"="%3A"; \
                     ";"="%3B"; \
                     "<"="%3C"; \
                     ">"="%3E"; \
                     "="="%3D"; \
                     "@"="%40"; \
                     "["="%5B"; \
                     "]"="%5D"; \
                     "^"="%5E"; \
                     "_"="%5F"; \
                     "`"="%60"; \
                     "{"="%7B"; \
                     "|"="%7C"; \
                     "}"="%7D"; \
                     "~"="%7E"};
    
    :set ($safeChar->"\n") "%0A";
    :set ($safeChar->"\"") "%22";
    :set ($safeChar->"\$") "%24";
    :set ($safeChar->"\?") "%3F";
    :set ($safeChar->"\\") "%5C";
    
    :for i from=0 to=([:len $url]-1) do={
        :local char [:pick $url $i];
        :if (($safeChar->$char)!=nil) do={
            :set char ($safeChar->$char);
        }
        :set safe "$safe$char";
    }    
    :return $safe;
}

:global telegramSendMessage;
:set telegramSendMessage do={
    :global encodeUrl;
    :local botToken $1;
    :local isSend false;
    :local params [:toarray ""];
    :local urlParams "";
    
    :if ($2 != nil) do={:set ($params->0) "chat_id=$[$encodeUrl $2]";};
    :if ($3 != nil) do={:set ($params->1) "text=$[$encodeUrl $3]";};
    :if ($4 != nil) do={:set ($params->2) "parse_mode=$[$encodeUrl $4]";};
    :if ($5 != nil) do={:set ($params->3) "reply_to_message_id=$[$encodeUrl $5]";};
    
    :if ([:len $params] > 0) do={
        :set urlParams "\?";
        :foreach p in=$params do={
            :set urlParams "$urlParams$p&";
        }
        :set urlParams [:pick $urlParams 0 ([:len $urlParams]-1)];
    }    
    
    do {
        :local result [/tool fetch url="https://api.telegram.org/bot$botToken/sendMessage$urlParams" output=user as-value];
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
    :global encodeUrl;
    :local botToken $1;
    :local params [:toarray ""];
    :local urlParams "";
    
    :if ($2 != nil) do={:set ($params->0) "offset=$[$encodeUrl $2]";};
    :if ($3 != nil) do={:set ($params->1) "limit=$[$encodeUrl $3]";};
    
    :if ([:len $params] > 0) do={
        :set urlParams "\?";
        :foreach p in=$params do={
            :set urlParams "$urlParams$p&";
        }
        :set urlParams [:pick $urlParams 0 ([:len $urlParams]-1)];
    }
    
    do {
        :local result [/tool fetch url="https://api.telegram.org/bot$botToken/getUpdates$urlParams" output=user as-value];
        :if (($result->"status") = "finished") do={
            :return ($result->"data");
        }
    } on-error={
        :return "";
    }
    :return "";
}