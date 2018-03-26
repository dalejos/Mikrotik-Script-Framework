#Version: 3.0 alpha
#Fecha: 23-03-2018
#RouterOS 6.41 y superior.
#Comentario: Para el funcionamiento adecuado se debe sincronizar la hora mediante el cliente ntp.
#            Instalar el paquete NTP y activar el cliente.
#            Verificar si no se tiene bloquedo el puerto UDP 123, de ser necesario para el funcionamiento del NTP client agregar la regla NAT:
#            add action=masquerade chain=srcnat comment="NTP NAT" protocol=udp src-port=123 to-ports=10000-20000
#            esta regla debeb tener prioridad sobre las demas src NAT.
#Requiere: module-arrays, module-base32, module-hmac

:global setLastError;
:local lScriptName "module-totp";

#TODO-BEGIN

:global generateTOTP;
:global generateTOTP do={
    :global decodeBase32;
    :global getInitializedArray;
    :global hmacSha1;
    :global mod;
    :global arrayClone;
    
    :local base32Secret $1;
    :local timeSeconds [:tonum $2];
    :local timeStepSeconds [:tonum $3];
    
    #:put "base32Secret: $base32Secret";
    #:put "timeSeconds: $timeSeconds";
    #:put "timeStepSeconds: $timeStepSeconds";
    
    :local key [$decodeBase32 $base32Secret];
    :local data [$getInitializedArray 8 0];
    :local value ($timeSeconds / $timeStepSeconds);

    #:put "value";
    #:put $value;
    #:put "data";
    #:put $data;
    
    :local index 7;
    
    :while (($index >= 0) && ($value > 0)) do={
        #:put "value en $index";
        #:put $value;
        :set ($data->$index) ($value & 0xFF);
        :set index ($index - 1);
        :set value ($value >> 8);
    }    
    
    #:put "key";
    #:put $key;
    #:put "value";
    #:put $value;
    #:put "data";
    #:put $data;
    
    :local hash [$hmacSha1 [$arrayClone $key] [$arrayClone $data]];
    
    #:put "hash";
    #:put $hash;
    
    :local offset (($hash->([:len $hash] - 1)) & 0xF);

    :local truncatedHash 0;
    
    :for index from=$offset to=($offset + 3) do={
        :set truncatedHash ($truncatedHash << 8);
        :set truncatedHash ($truncatedHash | (($hash->$index) & 0xFF));
    }

    :set truncatedHash ($truncatedHash & 0x7FFFFFFF);
    :set truncatedHash [$mod $truncatedHash 1000000];
    
    :return $truncatedHash;
}

#:global getCurrentTimestamp;

#:put [$generateTOTP "JKNHS6PZ37WYDBR2NWDLN36L4H7QGLAA" [$getCurrentTimestamp] 30];

#TODO-END

$setLastError 0 ("$lScriptName cargado.");