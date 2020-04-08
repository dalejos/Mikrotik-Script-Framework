:global telegramSendMessage;
:global telegramSendMessage do={
    :local telegramBotToken $1;
    :local telegramChatID $2;
    :local telegramMessage $3;
    :local isSend false;
    do {
        :local result [/tool fetch url=("https://api.telegram.org/bot" . $telegramBotToken . "/sendMessage\?chat_id=" . $telegramChatID \
            . "&text=" . $telegramMessage . "&parse_mode=Markdown") output=user as-value];
        :if (($result->"status") = "finished") do={
            :set isSend (($result->"data")~"\"ok\":true");
        }
    } on-error={
    }
    :return $isSend;
}