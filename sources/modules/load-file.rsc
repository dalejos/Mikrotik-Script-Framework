:global loadFile;
:set loadFile do={

	:local result;
	
	:onerror error=errorName in={
		:set result [/file/get [find where name=$1]];
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