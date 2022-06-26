#Version: 3.0 alpha
#Fecha: 22-08-2017
#RouterOS 6.40 y superior.
#Comentario: 

:global setLastError;
:local lScriptName "module-arrays";

#TODO-BEGIN

:global getInitializedArray;
:global getInitializedArray do={
    :local size $1;
    :local value [:tonum $2];
    :local result ({});
    :for index from=0 to=($size - 1) do={
        :set result ($result , $value);
    }
    :return $result;
}

:global arrayCopy;
:global arrayCopy do={
    :local src $1;
    :local srcPos [:tonum $2];
    :local dest $3;
    :local destPos [:tonum $4];
    :local length [:tonum $5];
    
    :for index from=$srcPos to=($srcPos + $length - 1) do={
        :set ($dest->$destPos) ($src->$index);
        :set destPos ($destPos + 1);
    }
    :return $dest;
}

:global arrayClone;
:global arrayClone do={
    :local src $1;
    :local dest ({});
    :local length [:len $src];
    
    :for index from=0 to=($length - 1) do={
        :set dest ($dest , $src->$index);
    }
    :return $dest;
}

#TODO-END

$setLastError 0 ("$lScriptName cargado.");