#Version: 7.0
#Fecha: 26-06-2022
#RouterOS: 7.10 y superior.
#Comentario:

:local buttonName "modeButton";

:global button;
:if ([:typeof $button] = "array") do={
	:if ([:typeof ($button->$buttonName)] = "array") do={
		:while (($button->$buttonName->"active") && (!($button->$buttonName->"completed"))) do={
			/delay delay-time=1;
			/log/info "MODE SCRIPT.";
			:set ($button->$buttonName->"completed") true;
		}
	}
}
