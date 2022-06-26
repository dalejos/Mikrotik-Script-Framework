:global format;
:set format do={
    :local src $1;
    :local length $2;
    :local lengthSrc [:len $src];
    
    :if ($lengthSrc < ($length)) do={
        :for index from=$lengthSrc to=($length - 1) do={
            :set src ($src . " ");
        }
    } else={
        :set src ([:pick $src 0 ($length - 1)] . " ");
    }
    :return $src;
}

:global getCurrentTimestamp;
:set getCurrentTimestamp do={
    :local date [/system clock get date];
    :local months ({"jan"=1;"feb"=2;"mar"=3;"apr"=4;"may"=5;"jun"=6;"jul"=7;"aug"=8;"sep"=9;"oct"=10;"nov"=11;"dec"=12});
    :local daysForMonths ({31;28;31;30;31;30;31;31;30;31;30;31});
    
    :local day [:tonum [:pick $date 4 6]];
    :local month ($months->[:pick $date 0 3]);
    :local year [:tonum [:pick $date 7 11]];
    
    :local leapDays (($year - 1968) / 4);
    
    :if ((($leapDays * 4) + 1968) = $year) do={
        :set leapDays ($leapDays - 1);
        :set ($daysForMonths->1) 29;
    }
    
    :local days ($day - 1);
    
    :if (($month - 1) > 0) do={
        :for index from=0 to=($month - 2) do={
            :set days ($days + ($daysForMonths->($index)));
        }
    }
        
    :local daysForYear 365;
    :local secondsForDay 86400;
    :local gmtOffset [/system clock get gmt-offset];
    
    :local now [/system clock get time];
    :local hour [:tonum [:pick $now 0 2]];
    :local minutes [:tonum [:pick $now 3 5]];
    :local seconds [:tonum [:pick $now 6 8]];

    :local timestamp ((((($year - 1970) * $daysForYear) + $leapDays + $days) * $secondsForDay) + ($hour * 3600) + ($minutes * 60) + seconds);
    
    :if ($gmtOffset <= $secondsForDay) do={
        :set timestamp ($timestamp - $gmtOffset);
    } else={
        :set timestamp ($timestamp + (-$gmtOffset&0x00000000FFFFFFFF));
    }
    
    :return $timestamp;    
}