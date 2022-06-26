:if ([:len [/system script job find script="script-telegram-log"]] > 1) do={
    :return 255;
}

:global lastLogId;
:global messagesLog;

:global telegramSendMessage;
:global telegramBotToken;
:global telegramChatID;

:local identity [/system identity get name];
:local filterTopics "^(system;error;critical|system;info;account)\$";

:foreach id in=[/log find topics~"$filterTopics"] do={
    :local lastIndex [:tonum ("0x" . [:pick $id 1 [:len $id]])];
    :if ($lastLogId < $lastIndex) do={
        :set lastLogId $lastIndex;
        :local logData [/log get $id];
        :set ($messagesLog->"id-$lastIndex") ($logData->"message");
    }
}

:foreach id,message in=$messagesLog do={
    :local send [$telegramSendMessage $telegramBotToken $telegramChatID $message];
    
    :if ($send) do={
        :set ($messagesLog->"$id");
    }
}