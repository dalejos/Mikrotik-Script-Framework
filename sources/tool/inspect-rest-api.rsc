{
	:global makePath;
	:set makePath do={
		:global isGetMethod;
		:local items [:toarray $1];
		:local pathReturn "";
		:foreach item in=$items do={
			:if (!([$isGetMethod $item])) do={
				:set pathReturn "$pathReturn/$item";
			}
		}
		:return $pathReturn;
	}
	
	:global isGetMethod;
	:set isGetMethod do={
		:local commandName "print|get";
		:return ($1 ~ $commandName);
	}
	
	:global getInspect;
	:set getInspect do={
		:local pathInspect $1;
		:local requestInspect $2;
		:local dataInspect [/console/inspect path=$pathInspect request=$requestInspect as-value];
		
		#Se agrega para corregir devolucion del array
		:if ([:len $dataInspect] > 0) do={
			:if ([:typeof ($dataInspect->0)] != "array") do={
				:set $dataInspect ({$dataInspect});
			}
		}
		:return $dataInspect;
	}


	:global inspectSyntax ;
	:set inspectSyntax do={
		:global getInspect;
	
	
		:local pathInspect $1;
		:local requestInspect "syntax";
		
		:if ([:len $requestInspect] = 0) do={
			:set requestInspect "self";
		}
		
		:local dataInspect [$getInspect $pathInspect "syntax"];
		
		:put "";
		:if ([:len $dataInspect] > 0) do={
			:put "- #### List of parameters for the command: ";
			:put "";
			:foreach item in=$dataInspect do={
				:if (($item->"symbol-type") = "explanation") do={
					:put ("    - **" . ($item->"symbol") . "**: " . ($item->"text"));
				}
			}
		}
	}


	:global inspectChild;
	:set inspectChild do={
		:global inspectChild;
		:global makePath;
		:global getInspect;
		:global isGetMethod;
	
	
		:local pathInspect $1;
		:local requestInspect "child";
		
		:if ([:len $requestInspect] = 0) do={
			:set requestInspect "self";
		}
		
		:local dataInspect [$getInspect $pathInspect $requestInspect];		
		
		:put "";
		:if ([:len $dataInspect] > 0) do={
			#:put "path=$pathInspect";
			#:put "request=$requestInspect";
			#:put "";
			:foreach item in=$dataInspect do={
				
				:if (($item->"type") = "self") do={
					:if (($item->"node-type") ~ "cmd") do={
						:if ([$isGetMethod ($item->"name")] = true) do={
							:put ("### API call: " . [$makePath $pathInspect]);
							:put "### Method: GET.";
							[$inspectSyntax $pathInspect];
						}
						
					} else={					
						:if (($item->"node-type") ~ "path|dir") do={
							:put ("## Path: " . [$makePath $pathInspect]);
						}
					}
				} else={				
					:if (($item->"type") = "child") do={
						:if (($item->"node-type") ~ "path|dir|cmd") do={
							[$inspectChild ("$pathInspect," . ($item->"name"))];
						}
					} else={
						:put "****************************************";
						:put "path=$pathInspect";
						:put "request=$requestInspect";
						:put "";
						:put $item;
						:put "****************************************";
					}
				}
			}
		}
	}

	:put "# Mikrotik RouterOS REST API";
	:put "";
	:put "-## URL base (HTTP access): http://<routers_IP>/rest";
	:put "-## URL base (HTTPS access): https://<routers_IP>/rest";
	:put "";
	[$inspectChild "ip,address"];
	#[$inspectChild "ip,address,add"];
}