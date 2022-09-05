// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "OpenZeppelin/openzeppelin-contracts@4.3.2/contracts/token/ERC20/IERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.3.2/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../interfaces/Uniswap.sol";

contract LiquidityManager {
    event LiquidityRemove(string Symbol, uint Amount);

    address private FACTORY;
    address private WETH;
    address private UNISWAP_V2_ROUTER;

    constructor(
        address _FACTORY,
        address _WETH,
        address _UNISWAP_V2_ROUTER
    ) public {
        FACTORY = _FACTORY;
        WETH = _WETH;
        UNISWAP_V2_ROUTER = _UNISWAP_V2_ROUTER;
    }

    function _addLiquidity(
        uint _amountA,
        uint _amountB,
        address _tokenB
    )
        internal
        returns (
            uint,
            uint,
            uint
        )
    {
        // uint balA = IERC20Metadata(_tokenA).balanceOf(address(this));
        // uint balB = IERC20Metadata(_tokenB).balanceOf(address(this));
        //IERC20(WETH).approve(UNISWAP_V2_ROUTER, _amountA);
        IERC20(_tokenB).approve(UNISWAP_V2_ROUTER, _amountB);

        (uint amountA, uint amountB, uint liquidity) = IUniswapV2Router(
            UNISWAP_V2_ROUTER
        ).addLiquidity(
                address(WETH),
                _tokenB,
                _amountA,
                _amountB,
                0,
                0,
                address(this),
                block.timestamp
            );
        return (amountA, amountB, liquidity);
    }

    function removeLiquidity(address _tokenA, address _tokenB) external {
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);

        uint liquidity = IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(UNISWAP_V2_ROUTER, liquidity);

        (uint amountA, uint amountB) = IUniswapV2Router(UNISWAP_V2_ROUTER)
            .removeLiquidity(
                _tokenA,
                _tokenB,
                liquidity,
                1,
                1,
                address(this),
                block.timestamp
            );

        emit LiquidityRemove(IERC20Metadata(_tokenA).symbol(), amountA);
        emit LiquidityRemove(IERC20Metadata(_tokenB).symbol(), amountB);
    }
}
