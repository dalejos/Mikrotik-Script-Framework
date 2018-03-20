#:global getHexFromByte;
#:global getHexFromByte do={
#    :local HEXDIGITS "0123456789ABCDEF";
#    :local byte [:tonum $1];
#    :local hex "";
#    :local index 0;
#    
#    if ([:typeof $byte] = "num") do={
#        :set index (($byte>>4)&0xF);
#        :set hex [:pick $HEXDIGITS $index];
#        :set index (($byte>>0)&0xF);
#        :set hex ($hex . [:pick $HEXDIGITS $index]);
#    }
#    :return $hex;
#}

:global printByteArrayToHex;
:global printByteArrayToHex do={
    :global getHexFromByte;
    :local array $1;
    :local str "";
    :local hex "";
    #:put $array;
    :for index from=0 to=([:len $array] - 1) do={
        :set hex [$getHexFromByte ($array->$index)];
        #:put $hex;
        :set str "$str$hex";
    }
    :put $str;
}

:global mod;
:global mod do={
    :local dividendo $1;
    :local divisor $2;
    :local resto ($dividendo / $divisor);
    :set resto ($divisor * $resto);
    :set resto ($dividendo - $resto);
    :return $resto;
}

:global getInitializedArray;
:global getInitializedArray do={
    :local size $1;
    :local value [:tonum $2];
    :local result ({});
    :for index from=0 to=($size - 1) do={
        :set result ($result , $value);
    }
    :return $result;
}

#    public static native void arraycopy(Object src,  int  srcPos,
#                                        Object dest, int destPos,
#                                        int length);

:global arrayCopy;
:global arrayCopy do={
    :local src $1;
    :local srcPos [:tonum $2];
    :local dest $3;
    :local destPos [:tonum $4];
    :local length [:tonum $5];
    
    :for index from=$srcPos to=($srcPos + $length - 1) do={
        :set ($dest->$destPos) ($src->$index);
        :set destPos ($destPos + 1);
    }
    :return $dest;
}

:global arrayClone;
:global arrayClone do={
    :local src $1;
    :local dest ({});
    :local length [:len $src];
    
    :for index from=0 to=($length - 1) do={
        :set dest ($dest , $src->$index);
    }
    :return $dest;
}


#Function padTheMessage
#   Param:
#   $1: data (array de byte).
#
:global padTheMessage;
:global padTheMessage do={
    :global mod;
    :global getInitializedArray;

    :local data $1;
    :local origLength [:len $data];
    :local tailLength [$mod $origLength 64];
    :local padLength 0;
    
    :if ((64 - tailLength) >= 9) do={
        :set padLength (64 - $tailLength);
    } else={
        :setb padLength (128 - $tailLength);
    }
    
#    :local thePad ({0x80});
#    :for index from=1 to=($padLength - 1) do={
#        :set thePad ($thePad , 0x00);
#    }
    
    :local thePad [$getInitializedArray $padLength 0];
    :set ($thePad->0) 0x80;
    
#    :put $data;
#    :put $thePad;
    
    :local lengthInBits ($origLength * 8);
#    :put "origLength: $origLength";
#    :put "lengthInBits: $lengthInBits";
#    :put (($lengthInBits >> (8 * 0)) & 0xF);
    
    :local index 0;
    
    :for cnt from=0 to=7 do={
        :set index ($padLength - 1 - $cnt);
        :set ($thePad->$index) (($lengthInBits >> (8 * cnt)) & 0x000000000000FF);
    }
    
#    :put $data;
#    :put $thePad;
    
#    :local result ({});
#    :set index 0;
#    :for i from=0 to=([:len $data] - 1) do={
#        :set result ($result , $data->$i);
#        :set index ($index + 1);
#    }
#    
#    :for i from=0 to=([:len $thePad] - 1) do={
#        :set result ($result , $thePad->$i);
#        :set index ($index + 1);
#    }
    :return ($data , $thePad);
}

:global rotateLeft;
:global rotateLeft do={
    :local value [:tonum $1];
    :local bits [:tonum $2];
    :return ((($value << $bits) | ($value >> (32 - $bits))) & 0x00000000FFFFFFFF);
}

:global bitInvertion;
:global bitInvertion do={
    :local value [:tonum $1];
    :return (-$value-1&0x00000000FFFFFFFF);
}

:global processTheBlock;
:global processTheBlock do={
    :global getInitializedArray;
    :global rotateLeft;
    :global bitInvertion;
    :global printByteArrayToHex;

    :local work $1;
    :local H $2;
    :local K $3;
    
    :local temp 0;
    :local A 0;
    :local B 0;
    :local C 0;
    :local D 0;
    :local E 0;
    :local F 0;
    
    :local W [$getInitializedArray 80 0];

    :for outer from=0 to=15 do={
        :set temp 0;
        :for inner from=0 to=3 do={
            :set temp ((($work->($outer * 4 + $inner)) & 0x00000000000000FF) << (24 - $inner * 8));
            :set ($W->$outer) (($W->$outer) | $temp);
        }
    }
    
    :for j from=16 to=79 do={
        :set ($W->$j) [$rotateLeft (($W->($j - 3)) ^ ($W->($j - 8)) ^ ($W->($j - 14)) ^ ($W->($j - 16))) 1];
    }
    
    :put "W";
    :put ($W);
    :put "H";
    :put ($H);
    

    :set A ($H->0);
    :set B ($H->1);
    :set C ($H->2);
    :set D ($H->3);
    :set E ($H->4);
    
    :put "B";
    :put "$B";
    :put [$bitInvertion $B];

    :for j from= 0 to=19 do={
        :set F (($B & $C) | ([$bitInvertion $B] & $D));
        :set temp (([$rotateLeft $A 5] + $F + $E + ($K->0) + ($W->$j)) & 0x00000000FFFFFFFF );

        :set E $D;
        :set D $C;
        :set C [$rotateLeft $B 30];
        :set B $A;
        :set A $temp;
    }
    
    :for j from=20 to=39 do={
        :set F ($B ^ $C ^ $D);
        :set temp (([$rotateLeft $A 5] + $F + $E + ($K->1) + ($W->$j)) & 0x00000000FFFFFFFF );

        :set E $D;
        :set D $C;
        :set C [$rotateLeft $B 30];
        :set B $A;
        :set A $temp;
    }
    
    :for j from=40 to=59 do={
        :set F (($B & $C) | ($B & $D) | ($C & $D));
        :set temp (([$rotateLeft $A 5] + $F + $E + ($K->2) + ($W->$j)) & 0x00000000FFFFFFFF );

        :set E $D;
        :set D $C;
        :set C [$rotateLeft $B 30];
        :set B $A;
        :set A $temp;
    }

    :for j from=60 to=79 do={
        :set F ($B ^ $C ^ $D);
        :set temp (([$rotateLeft $A 5] + $F + $E + ($K->3) + ($W->$j)) & 0x00000000FFFFFFFF );

        :set E $D;
        :set D $C;
        :set C [$rotateLeft $B 30];
        :set B $A;
        :set A $temp;
    }

    :put "A: $A";
    :put "B: $B";
    :put "C: $C";
    :put "D: $D";
    :put "E: $E";
    :set ($H->0) ((($H->0) + $A) & 0x00000000FFFFFFFF);
    :set ($H->1) ((($H->1) + $B) & 0x00000000FFFFFFFF);
    :set ($H->2) ((($H->2) + $C) & 0x00000000FFFFFFFF);
    :set ($H->3) ((($H->3) + $D) & 0x00000000FFFFFFFF);
    :set ($H->4) ((($H->4) + $E) & 0x00000000FFFFFFFF);
        
    :put "H";
    :put $H;
    :return $H;
}

:global fill;
:global fill do={
    :local value [:tonum $1];
    :local array $2;
    :local off [:tonum $3];
    
    :set ($array->($off + 0)) (($value >> 24) & 0xFF);
    :set ($array->($off + 1)) (($value >> 16) & 0xFF);
    :set ($array->($off + 2)) (($value >> 8) & 0xFF);
    :set ($array->($off + 3)) (($value >> 0) & 0xFF);
    
    :return $array;
}

:global sha1;
:global sha1 do={
    :global mod;
    :global getInitializedArray;
    :global padTheMessage;
    :global arrayCopy;
    :global arrayClone;
    :global processTheBlock;
    :global fill;
    :global printByteArrayToHex;
    
    :local data $1;
    :local paddedData [$padTheMessage $data];
    :local paddedLength [:len $paddedData];

    :put "paddedData";
    [$printByteArrayToHex $paddedData];    
    
    :local H {0x67452301; 0xEFCDAB89; 0x98BADCFE; 0x10325476; 0xC3D2E1F0};
    :put "INIT H";
    :put "$H";
    #:local H;
    :local K {0x5A827999; 0x6ED9EBA1; 0x8F1BBCDC; 0xCA62C1D6};

    :local paddedMod [$mod $paddedLength 64];
    :if ($paddedMod != 0) do={
        #Error
        :return ({});
    }
    
    :put ("paddedLength: " . $paddedLength);
    :local passesReq ($paddedLength / 64);
    :local work [$getInitializedArray 64 0];
    :put ("passesReq: " . $passesReq);
    
    :for passCntr from=0 to=($passesReq - 1) do={
        :set work [$arrayCopy $paddedData (64 * $passCntr) $work 0 64];
        :put "work";
        [$printByteArrayToHex $work];    
        :set H [$processTheBlock $work [$arrayClone $H] $K];
    }
    
    :local digest [$getInitializedArray 20 0];    

    :set digest [$fill ($H->0) $digest 0];
    :set digest [$fill ($H->1) $digest 4];
    :set digest [$fill ($H->2) $digest 8];
    :set digest [$fill ($H->3) $digest 12];
    :set digest [$fill ($H->4) $digest 16];
    
    :put "digest";
    [$printByteArrayToHex $digest];
    
    :return $digest;
}
