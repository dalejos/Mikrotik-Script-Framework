{

:global jsonTokenizer;

:global initialize do={
    :global jsonTokenizer;
    :if ([:typeof $1] = "str") do={
        :set jsonTokenizer {"index"=0;"length"=0;"char"="";"string"="$1"};
        :set ($jsonTokenizer->"length") [:len ($jsonTokenizer->"string")];
        :return true;
    }
    :return false;
}

:global nextChar do={
    :global jsonTokenizer;
    :if ((($jsonTokenizer->"index") >= 0) and (($jsonTokenizer->"index") < ($jsonTokenizer->"length"))) do={
        :set ($jsonTokenizer->"char") [:pick ($jsonTokenizer->"string") ($jsonTokenizer->"index")];
        :set ($jsonTokenizer->"index") (($jsonTokenizer->"index") + 1);
        :return true;
    }
    :return false;
}

:global a "\n"

:global isWhiteSpace do={
    :return (($1 = " ") or ($1 = "\10") or ($1 = "\09") or ($1 = "\0C"));
}


### TEST ###

:local test "{\"ok\":true}";

:put [$initialize $test];
}

:while ([$nextChar]) do={
    :put ($jsonTokenizer->"char");
}
