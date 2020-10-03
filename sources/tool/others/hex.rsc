:global byteToHex;
:set byteToHex do={
    :local byte [:tonum $1];
    do {
        :return "$[:pick "0123456789ABCDEF" (($byte >> 4) & 0xF)]$[:pick "0123456789ABCDEF" ($byte & 0xF)]";
    } on-error={
        :return "";
    }
}

:global byteToChar;
:set byteToChar do={
    :global byteToHex;
    :local hex [$byteToHex $1];
    :local result [:parse "{:return \"\\$hex\";}"];
    return [$result];
}

:for i from=0x00 to=0xFF do={
    :put [$byteToChar $i];
}



:global charToByte;
:set charToByte do={
    :local hexDigits "0123456789ABCDEF";
    :for i from=0 to=255 do={
        :put "$[:pick $hexDigits (($i >> 4) & 0xF)]$[:pick $hexDigits ($i & 0xF)]";
    }
}
