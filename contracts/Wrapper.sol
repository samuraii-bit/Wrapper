// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Wrapper {
    //address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address immutable myToken;
    address immutable stableCoin;

    IUniswapV2Pair immutable pair;

    IPyth pyth;
    
    bytes32 btcUsdPriceId;
 
    constructor(address _uniswapV2Router, address _factory, address _myToken, addresss _stableCoin, address _chainlinkOracle, address _pythOracle, bytes32 _btcUsdPriceId) {
        IUniswapV2Router02 router = IUniswapV2Router02(_uniswapV2Router);
        pair = IUniswapV2Pair(UniswapV2Library.pairFor(_factory, _myToken, _stableCoin));
        
        myToken = _myToken;
        stableCoin = _stableCoin;
        
        price0CumulativeLast = _pair.price0CumulativeLast(); // fetch the current accumulated price value (1 / 0)
        price1CumulativeLast = _pair.price1CumulativeLast(); // fetch the current accumulated price value (0 / 1)
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1) = _pair.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'ExampleOracleSimple: NO_RESERVES'); 

        pythOracle = IPyth(_pythOracle);
        chainlinkOracle = AggregatorV3Interface(_chainlinkOracle);
        btcUsdPriceId = _btcUsdPriceId;
    }        

    function getPythPrice() public view returns(uint256) {
        PythStructs.Price memory price = pyth.getPriceNoOlderThan(
            _btcUsdPriceId,
            60
        )
        return uint256(price.price);
    } 

    function getChainlinkPrice() public view returns(uint256) {
        (, int256 price, , , ) = chainlinkOracle.latestRoundData();
        return uint256(price);
    }

    function getTwapPrice() public view {
        
    }

    function addLiquidity(uint256 _myTokenAmount, uint256 _stableCoinAmount, uint256 _myTokenAmountDesired, uint256 _stableCoinAmountDesired) public {
        IERC20(stableCoin).transferFrom(msg.sender, address(this), _stableCoinAmount);
        uint256 myTokenAmount;
        if (_myTokenAmount > 0) {
            IERC20(myToken).transferFrom(msg.sender, address(this), _myTokenAmount);
            myTokenAmount = _myTokenAmount;
        }
        // дописать
       /* else {
            uint256 tokenPrice = getChainlinkPrice();
            myTokenAmount = (_stableCoinAmount * 1e18) / tokenPrice;
        } */ 

        IERC20(stableCoin).approve(router, _stableCoinAmount);
        IERC20(myToken).approve(router, myTokenAmount);
        
        router.addLiquidity(stableCoin, myToken, _stableCoinAmount, _myTokenAmount, 0, 0, msg.sender, block.timestamp() + 300);
    }

}