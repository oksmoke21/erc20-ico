// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./Crowdsale.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenSale is Crowdsale {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address private deployedToken;
    IERC20 private _token;

    uint private tokenQuantity = 100000000 * 10**18; // 100 million tokens divided into 10^18 subtokens
    uint private presaleQuantity = 30000000 * 10**18; // 30 million tokens at $0.015
    uint private secondSaleQuantity = 50000000 * 10**18; // 50 million tokens at $0.025
    uint private thirdSaleQuantity = 20000000 * 10**18; // 20 million tokens at $0.040

    uint private ratePresale = 12538424435117;
    uint private rateSecondsale = 208973740585287;
    uint private rateThirdsale = 334357984936460;
    // Cost per token in wei using conversion rate: 1 USD = 835,894,962,341,150 wei

    uint private correctionFactorPresale = 10**18/ratePresale; // 79,754
    uint private correctionFactorSecondsale = 10**18/rateSecondsale; // 4,785
    uint private correctionFactorThirdsale = 10**18/rateThirdsale; // 2,990

    uint private adjustedPresaleQuantity = presaleQuantity - correctionFactorPresale - 1;
    uint private adjustedSecondsaleQuantity = secondSaleQuantity - correctionFactorSecondsale - 1;
    uint private adjustedThirdsaleQuantity = thirdSaleQuantity - correctionFactorThirdsale - 1;

    constructor(uint256 rate, address payable wallet, IERC20 token) Crowdsale(rate, wallet, token) 
    {
        deployedToken = address(token);
        _token = token;
    }

    function _getTokenAmount(uint256 weiAmount) internal view override returns (uint256) {
        weiAmount = msg.value;
        uint totalTokensSoldTillNow = tokensSold();
        uint tokensToBeSent = _saleManager(totalTokensSoldTillNow, weiAmount);
        return tokensToBeSent;
    }

    // uint weiPresale = 376152733053510000000;

    function tokensSold() public view returns(uint) { // shows correct value after transferring tokens from admin to contract
        ERC20 myToken = ERC20(deployedToken);
        uint totalTokens = myToken.totalSupply();
        uint crowdsaleContractBalance = myToken.balanceOf(address(this));
        return totalTokens-crowdsaleContractBalance;
    }

    function _saleManager(uint totalTokensSoldTillNow, uint moneySent) internal view returns (uint){
        uint tokensToBeSent;
        uint saleRate;
        
        if(totalTokensSoldTillNow < presaleQuantity)
        {
            saleRate = ratePresale;
            if(totalTokensSoldTillNow > adjustedPresaleQuantity)
            {
                saleRate = rateSecondsale;
            }
        }
        else if(totalTokensSoldTillNow >= adjustedPresaleQuantity && totalTokensSoldTillNow < (presaleQuantity + secondSaleQuantity))
        {
            saleRate = rateSecondsale;
            if(totalTokensSoldTillNow > adjustedPresaleQuantity + adjustedSecondsaleQuantity)
            {
                saleRate = rateThirdsale;
            }
        }
        else saleRate = rateThirdsale;
        tokensToBeSent = (moneySent*(10**18))/saleRate;
        // tokens to be sent to investor have been determined

        if (saleRate == ratePresale)
        {
            require(tokensToBeSent + totalTokensSoldTillNow <= presaleQuantity,
            "Cannot proceed as tokens sold in pre-sale round exceed 30 mil");
        }
        else if (saleRate == rateSecondsale)
        {
            require(tokensToBeSent + totalTokensSoldTillNow <= (adjustedPresaleQuantity + adjustedSecondsaleQuantity),
            "Cannot proceed as tokens sold in second sale round exceed 50 mil");
        }
        else require(saleRate == rateThirdsale);
        return tokensToBeSent;
    }

    function showCurrentSale() public view returns(string memory) {
        string memory currentSale;
        if(tokensSold() == 0 || tokensSold() <= adjustedPresaleQuantity)
        {
            currentSale = "Presale round";
        }
        else if(tokensSold() <= adjustedSecondsaleQuantity)
        {
            currentSale = "Second sale round";
        }
        else currentSale = "Final sale round";
        return currentSale;
    }
}