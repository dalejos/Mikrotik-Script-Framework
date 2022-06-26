:global ipsec;
:if ([:typeof $ipsec] != "array") do={
    :set $ipsec {"count"=0; "totalCount"=3; "tx"=[:toarray ""]; "rx"=[:toarray ""]; "delay"=5s};
}