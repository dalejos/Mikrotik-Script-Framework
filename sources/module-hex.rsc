#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario: 

:global setLastError;
:local lScriptName "module-hex";

#TODO-BEGIN

:global getHexFromByte;
:global getHexFromByte do={
    :local HEXDIGITS "0123456789ABCDEF";
    :local byte [:tonum $1];
    :local hex "";
    :local index 0;
    
    if ([:typeof $byte] = "num") do={
        :set index (($byte>>4)&0xF);
        :set hex [:pick $HEXDIGITS $index];
        :set index (($byte>>0)&0xF);
        :set hex ($hex . [:pick $HEXDIGITS $index]);
    }
    :return $hex;
}

:local hex "";
:local cr "\r\n";
:local function ("{:local CHARBYTE ({});");
:for i from=0x00 to=0xFF do={
    :set hex [$getHexFromByte $i];
    :set function ($function . $cr . (":set (\$CHARBYTE->\"\\$hex\") 0x$hex;"));
}
:set function ($function . $cr . ":return \$CHARBYTE;}");
:set function [:parse $function];

:global CHARTOBYTE;
:set CHARTOBYTE [$function];

global stringToByteArray;
global stringToByteArray do={
    :global CHARTOBYTE;
    :local char "";
    :local result ({});
    :for index from=0 to=([:len $1]-1) do={
        :set char [:pick $1 $index]
        :set result ($result , ($CHARTOBYTE->"$char"));
        #:put ("$char: " . ($CHARTOBYTE->"$char"));
    }
    :return $result;
}

#TODO-END

$setLastError 0 ("$lScriptName cargado.");