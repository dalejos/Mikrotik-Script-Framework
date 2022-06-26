#Version: 3.0 alpha
#Fecha: 22-03-2020
#RouterOS 6.46.4 y superior.
#Comentario: 

:global toStringValue;
:set toStringValue do={
    :global toStringValue;
    :local inputVar $1;
    :local stringValue "";
        
    :if ([:typeof $inputVar] = "str") do={
        :set stringValue "\"$inputVar\"";
    } else={
        :if ([:typeof $inputVar] = "array") do={
            :if ([:len $inputVar] > 0) do={
                :foreach k,v in=$inputVar do={
                    :if ([:typeof $k] = "str") do={
                        :set stringValue ($stringValue . "\"" . $k ."\"=" . [$toStringValue $v] . ";");
                    } else={
                        :set stringValue ($stringValue . [$toStringValue $v] . ";");
                    }
                }
                :set stringValue ("{" . [:pick $stringValue 0 ([:len $stringValue] - 1)]. "}");
            } else={
                :set stringValue "[:toarray \"\"]";
            }
        } else={
            :set stringValue $inputVar;
        }
    }
    :return $stringValue;
}