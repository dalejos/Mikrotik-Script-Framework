
:local lEnvironment [/system script environment find];
:local lName;
:local lSize;

:foreach fEnvironment in=$lEnvironment do={
    :set lName [/system script environment get $fEnvironment name];
    :set lSize [:len [/system script environment get $fEnvironment value]];
    :put "Nombre: $lName - $lSize";
}