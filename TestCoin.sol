// SPDX-License-Identifier: GPL-3.0

// Author: Vladyslav Samoilenko
// Github: https://github.com/X-Vlad/ERC20

pragma solidity >=0.7.0 <0.9.0;

contract TestCoin {
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    string public constant name = "Test Coin";
    string public constant symbol = "TSC";
    uint8 public constant decimals = 8;

    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    mapping(address => bool) isBlacklisted;

	address public ownerToken;
	bool public paused;
    uint256 totalSupply_;

    constructor(uint256 total) {
      totalSupply_ = total * 10 ** decimals;
      balances[msg.sender] = totalSupply_;
	  ownerToken = msg.sender;
    }

    function totalSupply() public view returns (uint256) {
      return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }
	
    function setPaused(bool _paused) public {
        require(msg.sender == ownerToken, "You are not the owner");
        paused = _paused;
    }

    function blackList(address _user) public {
        require(!isBlacklisted[_user], "user already blacklisted");
        isBlacklisted[_user] = true;
    }

    function removeFromBlacklist(address _user) public {
        require(isBlacklisted[_user], "user already whitelisted");
        isBlacklisted[_user] = false;
    }

    function transfer(address _to, uint numTokens) public returns (bool) {
		require(paused == false, "Contract Paused");
	    require(!isBlacklisted[_to], "Recipient is backlisted");

        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] -= numTokens;
        balances[_to] += numTokens;
        emit Transfer(msg.sender, _to, numTokens);
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address _from, address _to, uint numTokens) public returns (bool) {
		require(paused == false, "Contract Paused");
		require(!isBlacklisted[_from], "Recipient is backlisted");
		
        require(numTokens <= balances[_from]);
        require(numTokens <= allowed[_from][msg.sender]);

        balances[_from] -= numTokens;
        allowed[_from][msg.sender] -= numTokens;
        balances[_to] += numTokens;
        emit Transfer(_from, _to, numTokens);
        return true;
    }
}
