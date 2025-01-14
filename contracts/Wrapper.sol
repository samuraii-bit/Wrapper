// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol";
import '@uniswap/lib/contracts/libraries/FixedPoint.sol';

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Wrapper {
    uint256 public constant PERIOD = 10 minutes;

    IUniswapV2Router02 public router;

    IUniswapV2Pair public immutable pair;
    address public immutable token0;
    address public immutable token1;
        
    address public immutable stableCoin;
    address public immutable myToken;

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public blockTimestampLast;
    
    FixedPoint.uq112x112 public price0Average;
    FixedPoint.uq112x112 public price1Average;

    AggregatorV3Interface chainlinkOracle;

    IPyth pythOracle;
    bytes32 btcUsdPriceId;

    event AddLiquidity(
        address _token0, 
        address _token1, 
        uint256 _token0AmountDesired, 
        uint256 _token1AmountDesired, 
        uint256 _token0Min,
        uint256 _token1Min,
        address _to, 
        uint256 _deadline
    );
 
    constructor(address _uniswapV2Router, address _factory, address _myToken, address _stableCoin, address _chainlinkOracle, address _pythOracle, bytes32 _btcUsdPriceId) {
        router = IUniswapV2Router02(_uniswapV2Router);
        
        pair = IUniswapV2Pair(UniswapV2Library.pairFor(_factory, _myToken, _stableCoin));
        
        stableCoin = _stableCoin;
        myToken = _myToken;

        token0 = pair.token0();
        token1 = pair.token1();
        
        price0CumulativeLast = pair.price0CumulativeLast(); // fetch the current accumulated price value (1 / 0)
        price1CumulativeLast = pair.price1CumulativeLast(); // fetch the current accumulated price value (0 / 1)

        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1) = pair.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'ExampleOracleSimple: NO_RESERVES'); 

        pythOracle = IPyth(_pythOracle);
        chainlinkOracle = AggregatorV3Interface(_chainlinkOracle);
        
        btcUsdPriceId = _btcUsdPriceId;
    }      

    function getPythPrice() public view returns(uint256) {
        PythStructs.Price memory price = pythOracle.getPriceNoOlderThan(
            btcUsdPriceId,
            60
        );
        return uint256(price.price);
    } 

    function getChainlinkPrice() public view returns(uint256) {
        (, int256 price, , , ) = chainlinkOracle.latestRoundData();
        return uint256(price);
    }

    function twapUpdate() internal {
        (uint256 price0Cumulative, uint256 price1Cumulative, uint256 blockTimeStamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(pair));
        uint256 timeElapsed = blockTimeStamp - blockTimestampLast;

        require(timeElapsed >= PERIOD, "Period not elapsed");
    
        price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - price0CumulativeLast) / timeElapsed));
        price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - price1CumulativeLast) / timeElapsed));

        price0CumulativeLast = price0Cumulative;
        price1CumulativeLast = price1Cumulative;
        blockTimestampLast = blockTimeStamp;
    }

    function getTwapPrice(address token, uint256 amountIn) public view returns (uint256 amountOut) {
        twapUpdate();
        if (token == token0) {
            amountOut = price0Average.mul(amountIn).decode144();
        }
        else {
            require(token == token1, "Invalid token");
            amountOut = price1Average.mul(amountIn).decode144();
        }
    }

    function addLiquidity(uint256 _myTokenAmount, uint256 _stableCoinAmount) public {
        require(_stableCoinAmount > 0, "U have to add non-zero stablecoin amount");
        IERC20(stableCoin).transferFrom(msg.sender, address(this), _stableCoinAmount);

        uint256 myTokenAmount;
        uint256 stableCoinAmount;
        if (_myTokenAmount > 0) {
            myTokenAmount = _myTokenAmount;
            stableCoinAmount = _stableCoinAmount;
        }
        else {
            stableCoinAmount = ((_stableCoinAmount / 2)  * 1e18);
            myTokenAmount = stableCoinAmount / getChainlinkPrice();
            require(myTokenAmount > 0, "Calculated token amount must be greater than zero");
            router.swapExactTokensForTokens(
                stableCoinAmount, 
                myTokenAmount, 
                [token0, token1], 
                msg.sender, 
                block.timestamp + 300
                );
        }
        IERC20(myToken).transferFrom(msg.sender, address(this), myTokenAmount); 

        IERC20(stableCoin).approve(router, stableCoinAmount);
        IERC20(myToken).approve(router, myTokenAmount);
        
        router.addLiquidity(
            stableCoin, 
            myToken, 
            stableCoinAmount, 
            myTokenAmount, 
            0, 
            0, 
            msg.sender, 
            block.timestamp + 300
        );
        
        emit AddLiquidity(
            stableCoin, 
            myToken, 
            stableCoinAmount, 
            myTokenAmount, 
            0, 
            0, 
            msg.sender, 
            block.timestamp + 300
            );
    }
}