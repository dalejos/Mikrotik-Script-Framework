:if ([:len [/system script job find script="script-telegram-active-users"]] > 1) do={
    :return 255;
}

:global lastUser;
:global messages;
:global telegramSendMessage;
:global telegramBotToken;
:global telegramChatID;

:local identity [/system identity get name];

:foreach id in=[/user active find] do={
    :local lastIndex [:tonum ("0x" . [:pick $id 1 [:len $id]])];
    :if ($lastUser < $lastIndex) do={
        :set lastUser $lastIndex;
        :local name [/user active get $id name];
        :local when [/user active get $id when];
        :local address [/user active get $id address];
        :local via [/user active get $id via];
        :set ($messages->"id-$lastIndex") "*$identity at $when*%0Auser *$name* logged in from *$address* via *$via*";
    }
}

:foreach id,message in=$messages do={
    :local send [$telegramSendMessage $telegramBotToken $telegramChatID $message];
    
    :if ($send) do={
        :set ($messages->"$id");
    }
}