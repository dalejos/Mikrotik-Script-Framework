/execute {
    :global monitorTrafficData;
    :global monitorTrafficConfig;
    :if ([:len ($monitorTrafficData->"ether1-wan")] = 0) do={
        :set ($monitorTrafficData->"ether1-wan") {"enable"=true; "data"={"count"=0;"sum"=0;"average"=0}};
    };
    :local enable ($monitorTrafficData->"ether1-wan"->"enable");
    :if (!$enable) do={
        :set ($monitorTrafficData->"ether1-wan"->"enable") true;
        :local up ($monitorTrafficConfig->"interfaces"->"ether1-wan"->"up");
        :if ([:len [/system script find where name="$up"]] > 0) do={
            /system script run "$up";
        };
        :delay ($monitorTrafficConfig->"delayForUp");
    };
    :set ($monitorTrafficData->"ether1-wan") {"enable"=true; "data"={"count"=0;"sum"=0;"average"=0}};
    /interface monitor-traffic ether1-wan interval=($monitorTrafficConfig->"interval") duration=($monitorTrafficConfig->"duration") do={
        :global monitorTrafficData;
        :local data ($monitorTrafficData->"ether1-wan"->"data");
        :local count (($data->"count") + 1);
        :local sum (($data->"sum") + ($"rx-bits-per-second"));
        :set ($monitorTrafficData->"ether1-wan"->"data") {"count"=$count;"sum"=$sum;"average"=($sum / $count)};
    };
    :local rxAverage ($monitorTrafficConfig->"interfaces"->"ether1-wan"->"rx-average");
    :local interfaceAverage ($monitorTrafficData->"ether1-wan"->"data"->"average");
    :if ($interfaceAverage < $rxAverage) do={
        :set ($monitorTrafficData->"ether1-wan"->"enable") false;
        :local down ($monitorTrafficConfig->"interfaces"->"ether1-wan"->"down");
        :if ([:len [/system script find where name="$down"]] > 0) do={
            /system script run "$down";
        };
    };
};