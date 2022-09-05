// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "OpenZeppelin/openzeppelin-contracts@4.3.2/contracts/token/ERC20/IERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.3.2/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../interfaces/Uniswap.sol";
//import "../interfaces/AggregatorV3Interface.sol";
import "./helpers.sol";
import "./LiquidityManager.sol";

contract FinalUniProject is LiquidityManager, helper {
    // Events
    event OptimalSwap(string Symbol, uint EthAmount);
    //(address PairAddress);
    //event AmountSwap(uint amount);
    event Log(
        string Symbol,
        uint indexed WethAmount,
        uint TokenXamount,
        uint liquidity
    );
    //event Amounts(uint[] amounts);
    //(uint amountA, uint amountB);

    // Globals
    address private UNISWAP_V2_ROUTER;
    //address private WETH;
    address[] private tokens;
    address private FACTORY;
    IERC20Metadata private WETH;

    constructor(
        address _UNISWAP_V2_ROUTER,
        address _WETH,
        address _FACTORY,
        address[] memory _tokens
    )
        public
        helper(_FACTORY)
        LiquidityManager(_FACTORY, _WETH, _UNISWAP_V2_ROUTER)
    {
        UNISWAP_V2_ROUTER = _UNISWAP_V2_ROUTER;
        WETH = IERC20Metadata(_WETH);
        FACTORY = _FACTORY;
        tokens = _tokens;
    }

    function InitialSwap(
        address _from, //Dai
        address _to, //Weth
        uint _amount
    ) external {
        IERC20(_from).transferFrom(msg.sender, address(this), _amount);
        IERC20(_from).approve(UNISWAP_V2_ROUTER, _amount);

        address[] memory path = new address[](2);
        path = new address[](2);
        path[0] = _from; //Dai
        path[1] = _to; //Weth

        uint[] memory amounts = IUniswapV2Router(UNISWAP_V2_ROUTER)
            .swapExactTokensForTokens(
                _amount,
                1,
                path,
                address(this), // Contract Now has Weth
                block.timestamp
            );
    }

    function FinalSwap(
        //address _tokenIn,
        //uint _amountIn,
        uint _amountOutMin // address _to
    ) external {
        //IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

        //IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);
        WETH.approve(UNISWAP_V2_ROUTER, WETH.balanceOf(address(this)));

        address[] memory path;
        path = new address[](2);
        //path[0] = _tokenIn;
        path[0] = address(WETH);

        uint portionedAmount = SlipageDivide(
            WETH.balanceOf(address(this)),
            tokens.length
        );

        for (uint i = 0; i < tokens.length; i++) {
            path[1] = tokens[i];
            address PairAddress = getPair(address(WETH), path[1]);
            //emit AddressPair(PairAddress);

            (uint reserve0, uint reserve1, ) = IUniswapV2Pair(PairAddress)
                .getReserves();

            uint swapAmount;
            if (IUniswapV2Pair(PairAddress).token0() == address(WETH)) {
                // if token0 = Dai
                // swap from token0 to token1
                swapAmount = getSwapAmount(reserve0, portionedAmount);
            } else {
                // swap from token1 to token0
                swapAmount = getSwapAmount(reserve1, portionedAmount); // if token1 = Dai
            }
            emit OptimalSwap(IERC20Metadata(path[1]).symbol(), swapAmount);

            // _form, _too
            //_swap(_tokenA, _tokenB, swapAmount);
            //_addLiquidity(_tokenA, _tokenB);

            uint[] memory amounts = IUniswapV2Router(UNISWAP_V2_ROUTER)
                .swapExactTokensForTokens(
                    swapAmount,
                    _amountOutMin,
                    path,
                    address(this),
                    block.timestamp
                );
            //emit Amounts(amounts);
            uint amountA = amounts[0];
            uint amountB = amounts[1];
            //(amountA, amountB);
            // IERC20Metadata(WETH).approve(UNISWAP_V2_ROUTER, amountA);
            //IERC20Metadata(path[1]).approve(UNISWAP_V2_ROUTER, amountB);

            (
                uint WethAmount,
                uint TokenXamount,
                uint liquidity
            ) = _addLiquidity(amountA, amountB, path[1]); // Tranfer to Seperate function!

            emit Log(
                IERC20Metadata(path[1]).symbol(),
                WethAmount,
                TokenXamount,
                liquidity
            );
            // Log(WETH, )

            //Optimal Swap( WETH, token(n) ) balance of each
        }
    }
}
