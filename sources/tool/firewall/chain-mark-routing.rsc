{
	:local routingTable "mi-routing-table";
	:local inputInterface "interfaz-de-entrada";
	:local specialPurposeAddress "special-purpose-address";
	:local sourceAddressList "$routingTable-address-list";
	
	
	:local chainName "routing-to-$routingTable";
	:local chainComment "routing to $routingTable";
	:local jumpComment "jump to $chainName";
	:local connectionMark "$routingTable-connection";
	:local packetMark "$routingTable-packet";
	
	:local routingCount [/routing/table/print count-only as-value where name=$routingTable];
	
	:if ($routingCount = 0) do={
		/routing/table/add name=$routingTable fib;
	}

	/ip/firewall/mangle/add action=mark-connection chain=input in-interface=$inputInterface comment="input $routingTable" connection-mark=no-mark new-connection-mark=$connectionMark passthrough=no disabled=yes
	/ip/firewall/mangle/add action=jump chain=output comment="output $jumpComment" connection-mark=$connectionMark jump-target=$chainName disabled=yes
	/ip/firewall/mangle/add action=jump chain=prerouting src-address-list=$sourceAddressList dst-address-list="!$specialPurposeAddress" comment="prerouting $jumpComment" jump-target=$chainName disabled=yes

	/ip/firewall/mangle/add action=passthrough chain=$chainName comment=$chainComment;
	/ip/firewall/mangle/add action=mark-connection chain=$chainName connection-mark=no-mark new-connection-mark=$connectionMark passthrough=yes
	/ip/firewall/mangle/add action=mark-packet chain=$chainName connection-mark=$connectionMark new-packet-mark=$packetMark packet-mark=no-mark passthrough=yes
	/ip/firewall/mangle/add action=mark-routing chain=$chainName new-routing-mark=$routingTable packet-mark=$packetMark passthrough=no
	/ip/firewall/mangle/add action=mark-routing chain=$chainName new-routing-mark=$routingTable passthrough=no
	/ip/firewall/mangle/add action=return chain=$chainName

}