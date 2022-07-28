// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    
    address public admin;
    uint private tokenQuantity = 100000000 * 10 ** decimals(); // 100 million tokens with 10^18 decimal places

    constructor() ERC20('TOKENVERSE', 'SOL') {
        admin = msg.sender;
        _mint(admin, tokenQuantity);
    }
}