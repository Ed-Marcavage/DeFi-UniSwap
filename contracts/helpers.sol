pragma solidity ^0.8;

import "OpenZeppelin/openzeppelin-contracts@4.3.2/contracts/utils/math/SafeMath.sol";
import "../interfaces/Uniswap.sol";

contract helper {
    using SafeMath for uint;
    address private FACTORY;

    constructor(address _FACTORY) public {
        FACTORY = _FACTORY;
    }

    function SlipageDivide(uint _amount, uint _numCoins)
        public
        pure
        returns (uint)
    {
        uint slipage = (_amount * 95) / 100;
        uint EthPerCoin = slipage / _numCoins;
        return EthPerCoin;
    }

    /*
        s = optimal swap amount
        r = amount of reserve for token a
        a = amount of token a the user currently has (not added to reserve yet)
        f = swap fee percent
        s = (sqrt(((2 - f)r)^2 + 4(1 - f)ar) - (2 - f)r) / (2(1 - f))
  */

    function getSwapAmount(uint r, uint a) public pure returns (uint) {
        return
            (sqrt(r.mul(r.mul(3988009) + a.mul(3988000))).sub(r.mul(1997))) /
            1994;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function getPair(address _tokenA, address _tokenB)
        internal
        view
        returns (address)
    {
        return IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);
    }
}
