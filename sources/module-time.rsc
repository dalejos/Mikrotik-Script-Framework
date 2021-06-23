#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario: 

:global setLastError;
:local lScriptName "module-time";

#TODO-BEGIN

#Function getTimestamp
#   Param:
#   $1: Date.
#   $2: Time.
#   $3: Gmt.
#
:global getTimestamp;
:global getTimestamp do={
    :local date $1;
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
        
    :local now $2;
    :local hour [:tonum [:pick $now 0 2]];
    :local minutes [:tonum [:pick $now 3 5]];
    :local seconds [:tonum [:pick $now 6 8]];
    
    :local daysForYear 365;
    :local secondsForDay 86400;
    :local gmtOffset $3;

    :local timestamp ((((($year - 1970) * $daysForYear) + $leapDays + $days) * $secondsForDay) + ($hour * 3600) + ($minutes * 60) + seconds);
    
    :if ($gmtOffset <= $secondsForDay) do={
        #+
        :set timestamp ($timestamp - $gmtOffset);
    } else={
        #-
        :set timestamp ($timestamp + (-$gmtOffset&0x00000000FFFFFFFF));
    }
    
    :return $timestamp;    
}

:global getCurrentTimestamp;
:global getCurrentTimestamp do={
    :global getTimestamp;
    :return [$getTimestamp [/system clock get date] [/system clock get time] [/system clock get gmt-offset]];
}

:global getDateTimeFromTimestamp;
:global getDateTimeFromTimestamp do={
    
}


{
    :local timestamp 1602476374;
    :local hour (1602476374 / 3600);
    :local sec (1602476374 % 3600);
    :local min ($sec / 60);
    :set sec ($sec % 60);
    
    :local day ($hour / 24);
    :set hour ($hour % 24);
    
    :local year (($day / 365) + 1970);
    :set day ($day % 365);
    
    :local dayMonth {31;28;31;30;31;30;31;31;30;31;30;31};
    :local month 1;
    :foreach m in=$dayMonth do={
        :if (($day - $m) > 0) do={
            :set day ($day - $m);
            :set month ($month + 1);
        }
    }

    :local leapDays (($year - 1968) / 4);
    
    :set ($day - )
    

    :put "timestamp: $timestamp";
    :put "Time: $leapDays $day/$month/$year $hour:$min:$sec";
}

#TODO-END

$setLastError 0 ("$lScriptName cargado.");