:global dataRipe;
:set dataRipe do={
    :local callBack $1;
    :local urlParams $2;
        
    :do {
        :local result [/tool fetch url="https://stat.ripe.net/data/$callBack/data.json?$urlParams" output=user as-value];
        :if (($result->"status") = "finished") do={
            :return ($result->"data");
        }
    } on-error={
        :return "";
    }
    :return "";
}