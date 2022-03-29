pragma solidity >=0.4.22 <0.9.0;

contract Storage
{
	uint data;
	constructor ()
	{
		data = 0;
	}

	event putVarEvent(uint _d, address sender);

	function putVar(uint _d) public
	{
		data = _d;
		emit putVarEvent(_d, msg.sender);
	}

	function getVar() view public returns (uint d)
	{
		return data;
	}
}