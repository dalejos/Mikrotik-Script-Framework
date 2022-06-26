:global readKey do={
    :return [/terminal inkey];
}

:global readLn do={
    :local msg "$1";
    :local line "";
    :local key;
    do {
        :put "$msg$line  ";
        :set key [/terminal inkey];
        :if ($key != 8) do={
            :set line "$line$key";        
        } else={
            :set line [:pick $line 0 ([:len $line]-1)];
        }
        /terminal cuu;
    } while=($key!=13);
    :return $line;
}