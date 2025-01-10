import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";

IUniswapV3Factory public immutable uniswapFactory;

constructor(
    address _uniswapFactory,
    ...
) {
    uniswapFactory = IUniswapV3Factory(_uniswapFactory);
    ...
}

function createPool(
    address tokenA,
    address tokenB,
    uint24 fee,
    uint160 sqrtPriceX96
) external onlyOwner returns (address pool) {
    pool = uniswapFactory.createPool(tokenA, tokenB, fee);
    IUniswapV3Pool(pool).initialize(sqrtPriceX96);
    return pool;
}
