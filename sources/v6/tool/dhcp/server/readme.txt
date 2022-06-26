PASOS PARA INSTALACION

1 - Configurar los parametros en el archivo config-dhcp-lease.

2 - Agregar al repositorio de scritps los siguientes scripts:
    - config-dhcp-lease
    - module-functions
    - dhcp-lease-script
    
3 - Instalar el dhcp-lease-server en la seccion script del DHCP server.

4 - Crear un scheduler para correr al inicio del router los scripts:
    - config-dhcp-lease
    - module-functions

5 - Crear un scheduler para correr periodicamente entre 1 y 5 minutos el siguiente script:
    - config-dhcp-lease
    - module-functions
    - dhcp-lease-script

6 - Reiniciar el router.

7 - Limpiar los leases concedidos del servidor DHCP.