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

:local getFileStream;
:set getFileStream do={
	:local fileStream [/file/print as-value where name=$1];
	:if ([:len $fileStream] > 0) do={
		:set fileStream ($fileStream->0);
		:set ($fileStream->"exists") true;
		:set ($fileStream->"buffer") "";
		:set ($fileStream->"bufferSize") 0;
		:set ($fileStream->"cs") 32768;
		:set ($fileStream->"os") 0;
		:set ($fileStream->"canRead") (($fileStream->"size") > ($fileStream->"os"));
	} else={
		:set $fileStream ({"exists"=false});
	}
	:return $fileStream;
}

:local readFile;
:set readFile do={
	:local fileStream $1;
	:if (($fileStream->"os") < ($fileStream->"size")) do={
		:set ($fileStream->"buffer") ([/file/read file=($fileStream->"name") offset=($fileStream->"os") chunk-size=($fileStream->"cs") as-value]->"data");
		:set ($fileStream->"bufferSize") [:len ($fileStream->"buffer")];
		:set ($fileStream->"os") (($fileStream->"os") + ($fileStream->"cs"));
	}
	:set ($fileStream->"canRead") (($fileStream->"size") > ($fileStream->"os"));
	:return $fileStream;
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
:local fileName "lista.txt";

:local fileStream [$getFileStream $fileName];

:put $fileStream;

:if ($fileStream->"exists") do={
	:local line "";
	:local charAt "";
	:while ($fileStream->"canRead") do={
		:set fileStream [$readFile $fileStream];
		
		:local index 0;
		:while ($index <= ($fileStream->"bufferSize")) do={
			:set charAt [:pick ($fileStream->"buffer") $index ($index + 1)];

			:if (($charAt = "\n") || ($charAt = "\r")) do={
				:if ([:len $line] > 0) do={


					:if ([$isIPv4 $line]) do={
						:if (!([:find ($dataList->"ipv4") $line] >= 0)) do={
							:put "Cargando IPv4: $line";
							:set ($dataList->"ipv4") (($dataList->"ipv4"), $line);
						} else={
							:put "Ignorando IPv4 duplicada: $line";
						}
					} else={
						:if ([$isAS $line]) do={
							:if (!([:find ($dataList->"as") $line] >= 0)) do={
								:put "Cargando AS: $line";
								:set ($dataList->"as") (($dataList->"as"), $line);
							} else={
								:put "Ignorando AS duplicado: $line";
							}
						} else={
							:if ([$isSegmentIPv4 $line]) do={
								:if (!([:find ($dataList->"segment") $line] >= 0)) do={
									:put "Cargando segmento: $line";
									:set ($dataList->"segment") (($dataList->"segment"), $line);
								} else={
									:put "Ignorando segmento duplicado: $line";
								}
							} else={
								:if ([$isDomain $line]) do={
									:if (!([:find ($dataList->"domain") $line] >= 0)) do={
										:put "Cargando dominio: $line";
										:set ($dataList->"domain") (($dataList->"domain"), $line);
									} else={
										:put "Ignorando dominio duplicado: $line";
									}
								} else={
									
								}							
							}
						}
					}
					:set $line "";
				}
			} else={
				:set line ($line . $charAt);
			}
			
			:set index ($index + 1);
		}
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
				:put "Ignorando segmento duplicado: $segment";
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
					:put "Ignorando segmento, $iSegment en segmento $jSegment";
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
				:put "Ignorando IP, $ipv4 en segmento $segment";
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
			:put "Direccion $item ya existe en la lista $listName";
		}
	}

	:foreach item in=($dataList->"segment") do={
		:local addressId [/ip/firewall/address-list/find where list=$listName address=$item !dynamic];
		:if (!([:len $addressId] > 0)) do={
			:put "Agregando $item a la lista $listName";
			/ip/firewall/address-list/add address=$item list=$listName comment="script segment - $listName";
		} else={
			:put "Direccion $item ya existe en la lista $listName";
		}
	}

	:foreach item in=($dataList->"domain") do={
		:local addressId [/ip/firewall/address-list/find where list=$listName address=$item !dynamic];
		:if (!([:len $addressId] > 0)) do={
			:put "Agregando $item a la lista $listName";
			/ip/firewall/address-list/add address=$item list=$listName comment="script domain - $listName";
		} else={
			:put "Direccion $item ya existe en la lista $listName";
		}
	}
	
} else={
	:put ("Archivo no existe.");
}