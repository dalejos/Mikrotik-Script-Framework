#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario: 
#Requiere: module-arrays, module-sha1

:global setLastError;
:local lScriptName "module-hmac";

#TODO-BEGIN

:global hmacSha1;
:global hmacSha1 do={
    :global sha1;
    :global arrayClone;
    :global getInitializedArray;
    #:global printByteArrayToHex;
    
    :local key $1;
    :local data $2;
    :local keyLength [:len $key];
    
    :local blockSize 0x40; #64
    :local opad 0x5C; #92
    :local ipad 0x36; #54
    
    :if ($keyLength > $blockSize) do={
        :set key [$sha1 [$arrayClone $key]];
    }
    
    :if (keyLength < $blockSize) do={
        :for index from=$keyLength to=($blockSize - 1) do={
            :set ($key->$index) 0x0;
        }
    }
    
    :local oKeyPad [$getInitializedArray $blockSize 0];
    :local iKeyPad [$getInitializedArray $blockSize 0];
    
    :for index from=0 to=($blockSize - 1) do={
        :set ($oKeyPad->$index) ($opad ^ ($key->$index));
        :set ($iKeyPad->$index) ($ipad ^ ($key->$index));
    }

    :local iSha ($iKeyPad , $data);
    :local hmacSha [$sha1 $iSha];
    
    :local oSha ($oKeyPad , $hmacSha);
    :set hmacSha [$sha1 $oSha];
    
    #:put "hmacSha";
    #[$printByteArrayToHex $hmacSha];
    
    
    :return $hmacSha;
}

#:global stringToByteArray;

#$hmacSha1 [$stringToByteArray "123456"] [$stringToByteArray "Hola"];

#TODO-END

$setLastError 0 ("$lScriptName cargado.");