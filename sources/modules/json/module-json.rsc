:global modules;
:if ([:typeof $modules] != "array") do={
    :set $modules [:toarray ""];
}

:local moduleInfo {"version"=1};

:set ($modules->"module-json") $moduleInfo;

:global getAll do={
    :local path "$1";
    :local where "";
    :if ([:len $2] > 0) do={
        :set where "where $2";
    }
    :local result [:toarray ""];
    :local ids [[:parse "$path find $where"]];
    :foreach id in=$ids do={
        :local item [[:parse "$path get $id"]];
        :set result ($result , {$item});
    }
    :return $result;
}

:global toJson do={
    :global toJson;
    :local result "";
    :if ([:typeof $1] = "array") do={
        :if ([:len $1] > 0) do={
            :if (!any ($1->0)) do={
#               object
                :set result "{";
                :local comma "";
                :foreach k,v in=$1 do={
                    :set result ($result . "$comma\"$k\":" . [$toJson $v]);
                    :if ($comma="") do={
                        :set comma ",";
                    }
                }
                :return ($result . "}");
            } else={
#               array
                :set result "[";
                :local comma "";
                :foreach v in=$1 do={
                    :set result ($result . "$comma" . [$toJson $v]);
                    :if ($comma="") do={
                        :set comma ",";
                    }
                }
                :return ($result . "]");
            }
        } else={
            :return [:toarray ""];
        }
    } else={
        :if ([:typeof $1] = "str" || [:typeof $1] = "id" || [:typeof $1] = "ip" \
             || [:typeof $1] = "ip-prefix" || [:typeof $1] = "ip6" || [:typeof $1] = "ip6-prefix") do={
            :return "\"$1\"";
        } else={
            :if ([:typeof $1] = "num" || [:typeof $1] = "bool") do={
                :return "$1";
            } else={
                :if ([:typeof $1] = "nothing" || [:typeof $1] = "nil" || $1 = null) do={
                    :return "null";
                } else={
                    :return ("\"" . [:typeof $1] . ": $1\"");
                }
            }
        }    
    }
}

:global json [:toarray ""];

:set ($json->"len") 0;
:set ($json->"in") "";
:set ($json->"pos") 0;
:set ($json->"debug") false;

:set ($json->"skipWhiteSpaces") do={
    :global json;    
    :while (($json->"pos") < ($json->"len") and ([:pick ($json->"in") ($json->"pos")] ~ "[ \r\n\t]")) do={
        :set ($json->"pos") (($json->"pos") + 1);
    }
}

:set ($json->"parse") do={
    :global json;
    :local Char;

#    :if (!$1) do={
#        :set ($json->"pos") 0;
#    }

    [($json->"skipWhiteSpaces")];
    :set Char [:pick ($json->"in") ($json->"pos")];
      
    :if ($Char="{") do={
        :set ($json->"pos") (($json->"pos") + 1);
        :return [($json->"parseObject")];
    } else={
        :if ($Char="[") do={
            :set ($json->"pos") (($json->"pos") + 1);
            :return [($json->"parseArray")];
        } else={
            :if ($Char="\"") do={
                :set ($json->"pos") (($json->"pos") + 1);
                :return [($json->"parseString")];
            } else={
                :if ($Char~"[eE0-9.+-]") do={
                    :return [($json->"parseNumber")];
                } else={
                    :if ($Char="n" and [:pick ($json->"in") ($json->"pos") (($json->"pos") + 4)]="null") do={
                        :set ($json->"pos") (($json->"pos") + 4);
                        :return [];
                    } else={
                        :if ($Char="t" and [:pick ($json->"in") ($json->"pos") (($json->"pos") + 4)]="true") do={
                            :set ($json->"pos") (($json->"pos") + 4);
                            :return true;
                        } else={
                            :if ($Char="f" and [:pick ($json->"in") ($json->"pos") (($json->"pos") + 5)]="false") do={
                                :set ($json->"pos") (($json->"pos") + 5);
                                :return false;
                            } else={
                                :put "Err.Raise 8732. No JSON object";
                                :set ($json->"pos") (($json->"pos") + 1);
                                :return [];
                            }
                        }
                    }
                }
            }
        }
    }
}

:set ($json->"parseString") do={
    :global json;
    :local unicodeToUTF8 ($json->"unicodeToUTF8");
    
    :local Char;
    :local StartIdx;
    :local Char2;
    :local TempString "";
    :local UTFCode;
    :local Unicode;

    :set StartIdx ($json->"pos");
    :set Char [:pick ($json->"in") ($json->"pos")];
  
    :while (($json->"pos") < ($json->"len") and $Char != "\"") do={
        :if ($Char="\\") do={
            :set Char2 [:pick ($json->"in") (($json->"pos") + 1)];
            :if ($Char2 = "u") do={
                :set UTFCode [:tonum ("0x" . [:pick ($json->"in") (($json->"pos") + 2) (($json->"pos") + 6)])];
                :if ($UTFCode>=0xD800 and $UTFCode<=0xDFFF) do={
# Surrogate pair
                    :set Unicode  (($UTFCode & 0x3FF) << 10);
                    :set UTFCode [:tonum ("0x" . [:pick ($json->"in") (($json->"pos") + 8) (($json->"pos") + 12)])];
                    :set Unicode ($Unicode | ($UTFCode & 0x3FF) | 0x10000);
                    :set TempString ($TempString . [:pick ($json->"in") $StartIdx ($json->"pos")] . [$unicodeToUTF8 $Unicode]);
                    :set ($json->"pos") (($json->"pos") + 12);
                } else={
# Basic Multilingual Plane (BMP)
                    :set Unicode $UTFCode;
                    :set TempString ($TempString . [:pick ($json->"in") $StartIdx ($json->"pos")] . [$unicodeToUTF8 $Unicode]);
                    :set ($json->"pos") (($json->"pos") + 6);
                }
                :set StartIdx ($json->"pos");
            } else={
                :if ($Char2 ~ "[\\bfnrt\"]") do={
                    :set TempString ($TempString . [:pick ($json->"in") $StartIdx ($json->"pos")] . [[:parse "(\"\\$Char2\")"]]);
                    :set ($json->"pos") (($json->"pos") + 2);
                    :set StartIdx ($json->"pos");
                } else={
                    :if ($Char2 = "/") do={
                        :set TempString ($TempString . [:pick ($json->"in") $StartIdx ($json->"pos")] . "/");
                        :set ($json->"pos") (($json->"pos") + 2);
                        :set StartIdx ($json->"pos");
                    } else={
                        :put "Err.Raise 8732. Invalid escape";
                        :set ($json->"pos") (($json->"pos") + 2);
                    }
                }
            }
        } else={
            :set ($json->"pos") (($json->"pos") + 1);
        }
        :set Char [:pick ($json->"in") ($json->"pos")];
    }
    :set TempString ($TempString . [:pick ($json->"in") $StartIdx ($json->"pos")]);
    :set ($json->"pos") (($json->"pos") + 1);
    :return $TempString;
}

:set ($json->"parseNumber") do={
    :global json;    
    :local StartIdx
    :local NumberString
    :local Number

    :set StartIdx ($json->"pos");
    :set ($json->"pos") (($json->"pos") + 1);
    :while (($json->"pos") < ($json->"len") and [:pick ($json->"in") ($json->"pos")]~"[eE0-9.+-]") do={
        :set ($json->"pos") (($json->"pos") + 1);
    }
    :set NumberString [:pick ($json->"in") $StartIdx ($json->"pos")];
    :set Number [:tonum $NumberString];
    :if ([:typeof $Number] = "num") do={
        :return $Number;
    } else={
        :return $NumberString;
    }
}

:set ($json->"parseArray") do={
    :global json;    
    :local Value;
    :local ParseArrayRet [:toarray ""];
    
    [($json->"skipWhiteSpaces")];
    :while (($json->"pos") < ($json->"len") and [:pick ($json->"in") ($json->"pos")]!= "]") do={
        :set Value [($json->"parse")];
        :set ($ParseArrayRet->([:len $ParseArrayRet])) $Value;
        [($json->"skipWhiteSpaces")];
        :if ([:pick ($json->"in") ($json->"pos")] = ",") do={
            :set ($json->"pos") (($json->"pos") + 1);
            [($json->"skipWhiteSpaces")];
        }
    }
    :set ($json->"pos") (($json->"pos") + 1);
    :return $ParseArrayRet;
}

:set ($json->"parseObject") do={
    :global json;
# Syntax :local ParseObjectRet ({}) don't work in recursive call, use [:toarray ""] for empty array!!!
    :local ParseObjectRet [:toarray ""];
    :local Key;
    :local Value;
    :local ExitDo false;
 
    [($json->"skipWhiteSpaces")];
    
    :while (($json->"pos") < ($json->"len") and [:pick ($json->"in") ($json->"pos")]!="}" and !$ExitDo) do={
        :if ([:pick ($json->"in") ($json->"pos")]!="\"") do={
            :put "Err.Raise 8732. Expecting property name";
            :set ExitDo true;
        } else={
            :set ($json->"pos") (($json->"pos") + 1);
            :set Key [($json->"parseString")];
            [($json->"skipWhiteSpaces")];
            :if ([:pick ($json->"in") ($json->"pos")] != ":") do={
                :put "Err.Raise 8732. Expecting : delimiter";
                :set ExitDo true;
            } else={
                :set ($json->"pos") (($json->"pos") + 1);
                :set Value [($json->"parse")];
                :set ($ParseObjectRet->$Key) $Value;
                [($json->"skipWhiteSpaces")];
                :if ([:pick ($json->"in") ($json->"pos")]=",") do={
                    :set ($json->"pos") (($json->"pos") + 1);
                    [($json->"skipWhiteSpaces")];
                }
            }
        }
    }
    :set ($json->"pos") (($json->"pos") + 1);
    :return $ParseObjectRet;
}

:set ($json->"byteToEscapeChar") do={
    :return [[:parse "(\"\\$[:pick "0123456789ABCDEF" (($1 >> 4) & 0xF)]$[:pick "0123456789ABCDEF" ($1 & 0xF)]\")"]];
}

:set ($json->"unicodeToUTF8") do={
    :global json;
    :local byteToEscapeChar ($json->"byteToEscapeChar");
    
    :local Nbyte;
    :local EscapeStr "";
    
    :if ($1 < 0x80) do={
        :set EscapeStr [$byteToEscapeChar $1];
    } else={
        :if ($1 < 0x800) do={
            :set Nbyte 2;
        } else={
            :if ($1 < 0x10000) do={
                :set Nbyte 3;
            } else={
                :if ($1 < 0x20000) do={
                    :set Nbyte 4;
                } else={
                    :if ($1 < 0x4000000) do={
                        :set Nbyte 5;
                    } else={
                        :if ($1 < 0x80000000) do={
                            :set Nbyte 6;
                        }
                    }
                }
            }
        }
        :for i from=2 to=$Nbyte do={
            :set EscapeStr ([$byteToEscapeChar ($1 & 0x3F | 0x80)] . $EscapeStr);
            :set $1 ($1 >> 6);
        }
        :set EscapeStr ([$byteToEscapeChar (((0xFF00 >> $Nbyte) & 0xFF) | $1)] . $EscapeStr);
    }
    :return $EscapeStr;
}

global jsonParse do={
    :global json;
    :set ($json->"in") $1;
    :set ($json->"pos") 0;
    :set ($json->"len") [:len $1];    
    :set ($json->"debug") false;
    
    :return [($json->"parse")];
}