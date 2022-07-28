# Task: ERC20 Token

The Token.sol and TokenSale.sol contracts are created to mint ERC20-compliant tokens and distribute them via the OpenZeppelin Crowdsale standard (Crowdsale.sol).

Steps to follow to deploy and run contracts-

1) Deploy Token.sol contract from admin address. Minted tokens will be stored at admin's address. This address will later receive the funds raised from the token sales.
2) Deploy TokenSale.sol, with parameters: rate = 1, wallet = admin's account address, token = deployed token contract's address.
3) Admin should transfer their tokens to the deployed TokenSale contract address by using Token contract's transfer() function.
4) Investors can now buy tokens of their desired capital investment by calling the buyTokens() function from TokenSale, with "address beneficiary" parameter being the address of the beneficiary of the purchased tokens
5) Investors can see which round (pre-sale, second sale, final sale) is currently going on by calling showCurrentSale()
