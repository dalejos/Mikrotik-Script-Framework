{
	:local whatsappData ({});
	
	:set ($whatsappData->"messaging_product") "whatsapp";
	:set ($whatsappData->"to") "584164581760";
	:set ($whatsappData->"type") "template";

	:local parameters {{"type"="text"; "text"="Luis F."}; {"type"="text"; "text"="32514"}; {"type"="text"; "text"="180USD"}};

	:local component {"type"="body"; "parameters"=$parameters};

	:local components {$component};

	:set ($whatsappData->"template") {"name"="parameter_test"; "language"={"code"="es_MX"}; "components"=$components};

	:put [$whatsappSendMessage [$toJson $whatsappData]]
}
