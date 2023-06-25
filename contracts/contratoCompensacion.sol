// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Compensacion {
    event Withdrawn(address indexed payee, uint256 weiAmount);

    function deposit() public payable {}

    function compensar(address payable user) public {
        uint amount = address(this).balance;
        (bool sent, bytes memory data) = user.call{value: amount}("");
        require(sent, "Failed to send Ether to delivery");
    }
}
