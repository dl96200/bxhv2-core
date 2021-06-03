
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import './interface/IMasterChef.sol';
import './interface/IBXH.sol';
import './uniswapv2/interfaces/IWHT.sol';
import  './uniswapv2/libraries/TransferHelper.sol';
import './bxhpool.sol';
import './uniswapv2/interfaces/IUniswapV2Factory.sol';
import './uniswapv2/interfaces/IUniswapV2Router02.sol';

contract BXHPool2 is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address public immutable WToken;
    BXHPool public bxhPool;
    IUniswapV2Factory public factory;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _multLP;

    // The BXH Token!
    IBXH public bxh;
   
    mapping(address => uint256) public tokenForLPID;
    mapping(address => address) public tokenForSwap;
    mapping(address => address) public tokenForLP;

    // Control mining
    bool public paused = false;
    IUniswapV2Router02 public router ;
    constructor(
        IBXH _bxh,
        BXHPool  _bxhpool,
        address _WToken,
        IUniswapV2Factory _factory,
        IUniswapV2Router02 _router
    ) public {
        bxh = _bxh;
        bxhPool = _bxhpool;
        WToken = _WToken;
        factory = _factory;
        router = _router;
    }

    function setPause() public onlyOwner {
        paused = !paused;
    }

    function setFactoryRouter(IUniswapV2Factory _factory,IUniswapV2Router02 _router) public onlyOwner{
        require(address(_factory) != address(0), "_factory is the zero address");
        require(address(_router) != address(0), "_router is the zero address");

        factory = _factory;
        router = _router;

    }

     // Add a new lp to the pool. Can only be called by the owner.
    function setPoolSwap(address token,address swapToken, uint256 pid) public onlyOwner {
        require(token != address(0), "token is the zero address");
        require(swapToken != address(0), "swapToken is the zero address");
        address pair = factory.getPair(token,swapToken);
        require(pair!=address(0x0),'pair not found');

        tokenForLPID[token] = pid;
        tokenForSwap[token] = swapToken;
        tokenForLP[token] = pair;
        

    }

    // Deposit LP tokens to Pool for BXH allocation.
    function deposit(address tokenA,uint256 amount,address to,uint256 deadline) public notPause {
        require(amount >0 ,' amount ?');
        require(address(tokenForSwap[tokenA]) != address(0), "swapToken is the zero address");

        uint256 amount2LP  =  amount.div(2);
        address tokenB = tokenForSwap[tokenA];
        address[] memory path = new address[](2);
        path[0]=tokenA;
        path[1]=tokenB;

        TransferHelper.safeTransferFrom(tokenA, msg.sender, address(this), amount);
        
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount2LP,0,path,address(this),deadline);

        uint256 balance1 = IERC20(tokenB).balanceOf(address(this));


        router.addLiquidity(tokenA,tokenB,0,balance1,0,balance1,address(this),deadline);

        uint256 balanceLP = IERC20(tokenForLP[tokenA]).balanceOf(address(this));
      
        //to pool
        bxhPool.deposit(tokenForLPID[tokenA],balanceLP,to);
        //return left amount
        uint256 balance0 = IERC20(tokenA).balanceOf(address(this));
        TransferHelper.safeTransfer(tokenA, msg.sender,  balance0);

    }

   
     // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyNative(uint256 amount) public onlyOwner {
        TransferHelper.safeTransferNative(msg.sender,amount)  ;
    }

    

    // Safe BXH transfer function, just in case if rounding error causes pool to not have enough BXHs.
    function safeBXHTransfer(address _to, uint256 _amount) internal {
        uint256 bxhBal = bxh.balanceOf(address(this));
        if (_amount > bxhBal) {
            bxh.transfer(_to, bxhBal);
        } else {
            bxh.transfer(_to, _amount);
        }
    }

    modifier notPause() {
        require(paused == false, "Mining has been suspended");
        _;
    }
}
