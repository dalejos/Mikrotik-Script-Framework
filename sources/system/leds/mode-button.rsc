#Version: 7.0
#Fecha: 16-07-2023
#RouterOS: 7.10 y superior.
#Comentario:

:local buttonName "modeButton";
:local seconds 60;
:local ledScript "mode-led";
:local ledName "led5";
:local runScript "mode-script";

:global button;
:if ([:typeof $button] != "array") do={
    :set $button [:toarray ""];
}

:if ([:typeof ($button->$buttonName)] != "array") do={
	:set ($button->$buttonName) {"active"=false; "ledScript"=$ledScript; "ledsName"=$ledName; "seconds"=$seconds; "countDown"=0; "runScript"=$runScript; "completed"=false};
}

:if (!($button->$buttonName->"active")) do={
	/log/info "MODE BUTTON: Iniciando tarea.";
	
	:set ($button->$buttonName->"active") true;
	
	:local scriptId [/system/script/find where name=($button->$buttonName->"ledScript")];
	:local scriptSource [/system/script/get $scriptId source];
	/execute script=$scriptSource;
	
	:set scriptId [/system/script/find where name=($button->$buttonName->"runScript")];
	:set scriptSource [/system/script/get $scriptId source];
	/execute script=$scriptSource;

	/log/info "MODE BUTTON: Tarea iniciada.";

	:set ($button->$buttonName->"countDown") ($button->$buttonName->"seconds");
	
	:while (($button->$buttonName->"active") && (!($button->$buttonName->"completed")) && (($button->$buttonName->"countDown") > 0)) do={
		/delay delay-time=1;
		:set ($button->$buttonName->"countDown") (($button->$buttonName->"countDown") - 1);
	}
	
	:set ($button->$buttonName->"active") false;
	
	/log/info "MODE BUTTON: Tarea finalizada.";
	
} else={
	:set ($button->$buttonName->"active") false;
}
