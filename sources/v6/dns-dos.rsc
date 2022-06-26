#Version: 3.0 alpha.
#Fecha: 22-12-2019.
#RouterOS 6.43 y superior.
#Comentario: Se introduce el calculo del delay para el API, 45 consultas por minuto.

#TODO-BEGIN

:local server 192.168.88.1;
:local serverPort 53;


:for index from=1 to=5 do={
    :local domainName "mikroterosyubiquiteros.ns$index.com";
#    /resolve server=$server server-port=$serverPort domain-name=$domainName;
    :do {
        /resolve domain-name=$domainName;
     } on-error={
     }
    :put $domainName;
}
#TODO-END