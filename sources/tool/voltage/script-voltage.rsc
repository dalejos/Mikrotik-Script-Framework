:local scriptName "script-voltage";
:if ([:len [/system script job find script=$scriptName]] > 1) do={
    :return 255;
}

:local strVoltage "";
:local strAverage "";
:local currentVoltage [/system health get voltage];
:local currentAverage 0;
:global voltage {"current"=$currentVoltage; "average"=$currentVoltage; count=1};

:while (true) do={
    :set currentVoltage [/system health get voltage];
    :set ($voltage->"current") $currentVoltage;
    :set ($voltage->"average") ($currentVoltage + ($voltage->"average"));
    :set ($voltage->"count") (($voltage->"count") + 1);
    :set currentAverage (($voltage->"average") / ($voltage->"count"));
    
    :set strVoltage "$($currentVoltage / 10).$($currentVoltage % 10)V";
    :set strAverage "$($currentAverage / 10).$($currentAverage % 10)V";
    :put "$strVoltage / $strAverage";
    :delay 1s;
}

{
    :local count 0;
    :while ($count < 3) do={
        :beep frequency=784 length=300ms;
        :delay 300ms;
        :beep frequency=880 length=300ms;
        :delay 200ms;
        :beep frequency=988 length=300ms;
        :delay 200ms;
        :beep frequency=988 length=300ms;
        :delay 200ms;
        :beep frequency=988 length=300ms;
        :delay 200ms;
        :beep frequency=988 length=300ms;
        :delay 200ms;
        :beep frequency=988 length=300ms;
        :delay 200ms;
        :beep frequency=988 length=300ms;
        :delay 400ms;
        :set count ($count + 1);
    }
}






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