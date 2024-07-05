
:local fetchFile;
:set fetchFile do={
    :return "";
}

:local isReserved;
:set isReserved do={
	:local dstIp $1;
	:return (($dstIp in 10.0.0.0/8) or ($dstIp in 172.16.0.0/12) or ($dstIp in 192.168.0.0/16) or \
		($dstIp in 169.254.0.0/16) or ($dstIp in 100.64.0.0/10) or ($dstIp in 0.0.0.0/8) or \
		($dstIp in 127.0.0.0/8) or ($dstIp in 224.0.0.0/4) or ($dstIp in 240.0.0.0/4) or \
		($dstIp in 255.255.255.255/32));
}

:local dataRipe;
:set dataRipe do={
    :local callBack $1;
    :local urlParams $2;
        
    do {
        :local result [/tool fetch url="https://stat.ripe.net/data/$callBack/data.json?$urlParams" output=user as-value];
        :if (($result->"status") = "finished") do={
            :return ($result->"data");
        }
    } on-error={
        :return "";
    }
    :return "";
}

:local loadFromJson;
:set loadFromJson do={
	:return [:deserialize $1 from=json];
}

:local loadFile;
:set loadFile do={

	:local result;
	:local errorName "";
	
	:onerror error=errorName in={
		:local fileId [/file/find where name=$1];
		:if (!([:len $fileId] > 0)) do={
			:error "Archivo $1 no encontrado.";
		}		
		:set result [/file/get $fileId];
		:local cs 32768;
		:local os 0;
		:local data "";
		:while ($os < ($result->"size")) do={
			:set data ($data . ([/file/read file=($result->"name") offset=$os chunk-size=$cs as-value]->"data"));
			:set os ($os + $cs);
		}
		:set ($result->"error") false;
		:set ($result->"message") "";
		:set ($result->"data") $data;
	} do={
		:set ($result->"error") true;
		:set ($result->"message") $errorName;
	}
	:return $result;
}

:local putInfo;
:set putInfo do={
	:put $1;
}

:local putWarning;
:set putWarning do={
	/terminal/style varname;
	:put $1;
	/terminal/style none;
}

:local putError;
:set putError do={
	/terminal/style error;
	:put $1;
	/terminal/style none;
}

:local putComment;
:set putComment do={
	/terminal/style comment;
	:put $1;
	/terminal/style none;
}

:local isIPv4;
:set isIPv4 do={
	:return ([:typeof [:toip $1]] = "ip");
}

:local isAS;
:set isAS do={
	:return ([:find $1 "AS"] = 0);
}

:local isDomain;
:set isDomain do={
	:onerror error=errorName in={
		:resolve $1;
		:return true;
	} do={
		:return false;
	}
}

:local isSegmentIPv4;
:set isSegmentIPv4 do={
	:local slash [:find $1 "/"];
	:if ($slash >= 0) do={
		:local ipAddress [:pick $1 0 $slash];
		:local cidr [:tonum [:pick $1 ($slash + 1) [:len $1]]];
		:if (($cidr >= 0) && ($cidr <= 32)) do={
			:return ([:typeof [:toip $ipAddress]] = "ip");
		}
	}
	:return false;
}

:local dataList ({});
:set ($dataList->"as") ({});
:set ($dataList->"ipv4") ({});
:set ($dataList->"segment") ({});
:set ($dataList->"domain") ({});

:local addressPath "";
:local listName "lista.txt";

:local listFile [$loadFile $listName];

:if (!($listFile->"error")) do={
	:local index 0;
	:local line "";
	:local charAt "";
	:local skipComment false;
	:local lineComment "";
	:while ($index <= ($listFile->"size")) do={
		:set charAt [:pick ($listFile->"data") $index ($index + 1)];
		:if (($charAt = "\n") || ($charAt = "\r")) do={
			:set skipComment false;
			:if ([:len $lineComment] > 0) do={
				[$putComment ("COMMENT: " . $lineComment)];
				:set lineComment "";
			}
			:if ([:len $line] > 0) do={


				:if ([$isIPv4 $line]) do={
					:if (![$isReserved $line]) do={	
						:if (!([:find ($dataList->"ipv4") $line] >= 0)) do={
							:put "Cargando IPv4: $line";
							:set ($dataList->"ipv4") (($dataList->"ipv4"), $line);
						} else={
							[$putWarning ("Ignorando IPv4 duplicada: " . $line)];
						}
					} else={
						[$putError ("Ignorando IPv4 privado: " . $line)];
					}
				} else={
					:if ([$isAS $line]) do={
						:if (!([:find ($dataList->"as") $line] >= 0)) do={
							:put "Cargando AS: $line";
							:set ($dataList->"as") (($dataList->"as"), $line);
						} else={
							[$putWarning ("Ignorando AS duplicado: " . $line)];
						}
					} else={
						:if ([$isSegmentIPv4 $line]) do={
							:if (![$isReserved $line]) do={	
								:if (!([:find ($dataList->"segment") $line] >= 0)) do={
									:put "Cargando segmento: $line";
									:set ($dataList->"segment") (($dataList->"segment"), $line);
								} else={
									[$putWarning ("Ignorando segmento duplicado: " . $line)];
								}
							} else={
								[$putWarning ("Ignorando segmento privado: " . $line)];
							}
						} else={
							:if ([$isDomain $line]) do={
								:if (!([:find ($dataList->"domain") $line] >= 0)) do={
									:put "Cargando dominio: $line";
									:set ($dataList->"domain") (($dataList->"domain"), $line);
								} else={
									[$putWarning ("Ignorando dominio duplicado: " . $line)];
								}
							} else={
								
							}							
						}
					}
				}


				:set $line "";
			}
		} else={
			:if (!($charAt = "#") && !$skipComment) do={
				:if (!($charAt = " ")) do={				
					:set line ($line . $charAt);
				}
			} else={
				:set skipComment true;
				:set lineComment ($lineComment . $charAt);
			}
		}
		:set index ($index + 1);
	}
	
# Cargando informacion de los AS desde ripe.net
	
	:local jsonASOverview;
	:local jsonResponse;	
	:foreach resource in=($dataList->"as") do={
		:put "";
		:put "Consultando $resource en ripe.net...";
		:set jsonASOverview [$loadFromJson [$dataRipe "as-overview" ("resource=$resource")]];
		:put ("AS holder: " . ($jsonASOverview->"data"->"holder"));
		:set jsonResponse [$loadFromJson [$dataRipe "ris-prefixes" ("resource=$resource&list_prefixes=true")]];
		:foreach segment in=($jsonResponse->"data"->"prefixes"->"v4"->"originating") do={		
			:if (!([:find ($dataList->"segment") $segment] >= 0)) do={
				:put "Cargando segmento: $segment";
				:set ($dataList->"segment") (($dataList->"segment"), $segment);
			} else={
				[$putWarning ("Ignorando segmento duplicado: " . $segment)];
			}
		}
	}	
	
#Optimizando segmentos

	:put "";
	:put "Optimizando segmentos...";
	:local segmentListTemp ({});
	:local ignoreSegment;
	:foreach iSegment in=($dataList->"segment") do={
		:set ignoreSegment false;
		:foreach jSegment in=($dataList->"segment") do={
			:if (!($iSegment = $jSegment)) do={
				:if ($iSegment in $jSegment) do={
					[$putWarning ("Ignorando segmento, " . $iSegment . " en segmento " . $jSegment)];
					:set ignoreSegment true;
				}
			}
		}
		:if (!$ignoreSegment) do={
			:set segmentListTemp ($segmentListTemp, $iSegment);
		}
	}
	
	:set ($dataList->"segment") $segmentListTemp;

#Optimizando IPs

	:put "";
	:put "Optimizando IPs...";
	:local ipv4ListTemp ({});
	:local ignoreIPv4;
	:foreach ipv4 in=($dataList->"ipv4") do={
		:set ignoreIPv4 false;
		:foreach segment in=($dataList->"segment") do={
			:if ($ipv4 in $segment) do={
				[$putWarning ("Ignorando IP, " . $ipv4 . " en segmento " . $segment)];
				:set ignoreIPv4 true;
			} else={
			}			
		}
		:if (!$ignoreIPv4) do={
			:set ipv4ListTemp ($ipv4ListTemp, $ipv4);
		}
		
	}
	
	:set ($dataList->"ipv4") $ipv4ListTemp;

#Agregando lista

	:local listName "bancos";

	:put "";
	:put "Creando lista...";
	:foreach item in=($dataList->"ipv4") do={
		:local addressId [/ip/firewall/address-list/find where list=$listName address=$item !dynamic];
		:if (!([:len $addressId] > 0)) do={
			:put "Agregando $item a la lista $listName";
			/ip/firewall/address-list/add address=$item list=$listName comment="script ipv4 - $listName";
		} else={
			[$putWarning ("Direccion " . $item . " ya existe en la lista " . $listName)];
		}
	}

	:foreach item in=($dataList->"segment") do={
		:local addressId [/ip/firewall/address-list/find where list=$listName address=$item !dynamic];
		:if (!([:len $addressId] > 0)) do={
			:put "Agregando $item a la lista $listName";
			/ip/firewall/address-list/add address=$item list=$listName comment="script segment - $listName";
		} else={
			[$putWarning ("Direccion " . $item . " ya existe en la lista " . $listName)];
		}
	}

	:foreach item in=($dataList->"domain") do={
		:local addressId [/ip/firewall/address-list/find where list=$listName address=$item !dynamic];
		:if (!([:len $addressId] > 0)) do={
			:put "Agregando $item a la lista $listName";
			/ip/firewall/address-list/add address=$item list=$listName comment="script domain - $listName";
		} else={
			[$putWarning ("Direccion " . $item . " ya existe en la lista " . $listName)];
		}
	}

	
} else={
	[$putError ("Error: " . ($listFile->"message"))];
}
