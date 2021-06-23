:global monitorTrafficConfig;
:foreach interface,data in=($monitorTrafficConfig->"interfaces") do={
    /execute "{ \
        :global monitorTrafficData; \
        :global monitorTrafficConfig; \
        :if ([:len (\$monitorTrafficData->\"$interface\")] = 0) do={ \
            :set (\$monitorTrafficData->\"$interface\") {\"enable\"=true; \"data\"={\"count\"=0;\"sum\"=0;\"average\"=0}}; \
        }; \
        :local enable (\$monitorTrafficData->\"$interface\"->\"enable\"); \
        :if (!\$enable) do={ \
            :set (\$monitorTrafficData->\"$interface\"->\"enable\") true; \
            :local up (\$monitorTrafficConfig->\"interfaces\"->\"$interface\"->\"up\"); \
            :if ([:len [/system script find where name=\"\$up\"]] > 0) do={ \
                /system script run \"\$up\"; \
            }; \
            :delay (\$monitorTrafficConfig->\"delayForUp\"); \
        }; \
        :set (\$monitorTrafficData->\"$interface\") {\"enable\"=true; \"data\"={\"count\"=0;\"sum\"=0;\"average\"=0}}; \
        /interface monitor-traffic $interface interval=(\$monitorTrafficConfig->\"interval\") duration=(\$monitorTrafficConfig->\"duration\") do={ \
            :global monitorTrafficData; \
            :local data (\$monitorTrafficData->\"$interface\"->\"data\"); \
            :local count ((\$data->\"count\") + 1); \
            :local sum ((\$data->\"sum\") + (\$\"rx-bits-per-second\")); \
            :set (\$monitorTrafficData->\"$interface\"->\"data\") {\"count\"=\$count;\"sum\"=\$sum;\"average\"=(\$sum / \$count)}; \
        }; \
        :local rxAverage (\$monitorTrafficConfig->\"interfaces\"->\"$interface\"->\"rx-average\"); \
        :local interfaceAverage (\$monitorTrafficData->\"$interface\"->\"data\"->\"average\"); \
        :if (\$interfaceAverage < \$rxAverage) do={ \
            :set (\$monitorTrafficData->\"$interface\"->\"enable\") false; \
            :local down (\$monitorTrafficConfig->\"interfaces\"->\"$interface\"->\"down\"); \
            :if ([:len [/system script find where name=\"\$down\"]] > 0) do={ \
                /system script run \"\$down\"; \
            }; \
        }; \
    };";
}