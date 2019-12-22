
:global commonCert {\
    "country"="VE";\
    "state"="LARA";\
    "locality"="Barquisimeto";\
    "organization"="MSF";\
    "unit"="TI";\
    "keySize"=2048;\
    "daysValid"=365
}

:global generateCert do={
    :local properties $1;
    /certificate
    {
        add name=($properties->"name") country=($properties->"country") state=($properties->"state") locality=($properties->"locality") \
            organization=($properties->"organization") unit=($properties->"unit") common-name=($properties->"commonName") key-size=($properties->"keySize") \
            days-valid=($properties->"daysValid") key-usage=($properties->"keyUsage");
    }
    
}

:global generateCA do={
    :global commonCert;
    :global generateCert;
    
    :local CA {\
        "name"="CA";\
        "country"=($commonCert->"country");\
        "state"=($commonCert->"state");\
        "locality"=($commonCert->"locality");\
        "organization"=($commonCert->"organization");\
        "unit"=($commonCert->"unit");\
        "commonName"=[/system identity get name];\
        "keySize"=($commonCert->"keySize");\
        "daysValid"=(($commonCert->"daysValid") * 5);\
        "keyUsage"="key-cert-sign,crl-sign"
    }
    
    $generateCert $CA;
}

#   $1: Certificado
:global sign do={
    :local certificate $1;
    :local caCrlHost $2;
    :local ca $3;
    /certificate
    {
        :if ([:len $ca] > 0) do={
            sign $certificate ca-crl-host=$caCrlHost ca=$ca;
        } else={
            sign $certificate ca-crl-host=$caCrlHost;
        }        
    }
}

:global generateServer do={
    :global commonCert;
    :global generateCert;
    
    :local name "opvn-server";
    
    :local server {\
        "name"=$name;\
        "country"=($commonCert->"country");\
        "state"=($commonCert->"state");\
        "locality"=($commonCert->"locality");\
        "organization"=($commonCert->"organization");\
        "unit"=($commonCert->"unit");\
        "commonName"="$name@$([/system identity get name])";\
        "keySize"=($commonCert->"keySize");\
        "daysValid"=(($commonCert->"daysValid") * 5);\
        "keyUsage"="digital-signature,key-encipherment,tls-server"
    }
    
    $generateCert $server;
}

:global generateClient do={
    :global commonCert;
    :global generateCert;
    
    :local name $1;
    
    :local server {\
        "name"=$name;\
        "country"=($commonCert->"country");\
        "state"=($commonCert->"state");\
        "locality"=($commonCert->"locality");\
        "organization"=($commonCert->"organization");\
        "unit"=($commonCert->"unit");\
        "commonName"="$name@$([/system identity get name])";\
        "keySize"=($commonCert->"keySize");\
        "daysValid"=(($commonCert->"daysValid") * 1);\
        "keyUsage"="digital-signature,tls-client"
    }
    
    $generateCert $server;
}
