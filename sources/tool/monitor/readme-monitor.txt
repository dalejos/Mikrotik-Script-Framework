PASOS PARA INSTALACION

1 - Configurar los parametros en el archivo config-monitor-traffic.

2 - Agregar al repositorio de scritps los siguientes scripts:
    - config-monitor-traffic
    - monitor-traffic
    
3 - Crear un scheduler para correr al inicio del router los scripts:
    - config-monitor-traffic

4 - Crear un scheduler para correr periodicamente entre 5 y 60 minutos el siguiente script:
    - monitor-traffic

5 - Reiniciar el router.