#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario:

#TODO-BEGIN

:global gModules;

:put "";
:put "########## Module Status ##########";
:put "";

:foreach kModule,fModule in=$gModules do={
	:put ("Modulo: $kModule - " . ($fModule->"name"));
	:put ("Descripcion: " . ($fModule->"description"));
	:put ("Habilitado: " . ($fModule->"enable"));
	:put ("Cargado: " . ($fModule->"loaded"));
	:put ("Config: " . ($fModule->"config"));
	:put "";
}

#TODO-END
