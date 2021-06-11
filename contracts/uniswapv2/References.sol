// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";

import  './libraries/TransferHelper.sol';
import './interfaces/IReferences.sol';

contract References is Ownable,ReentrancyGuard,IReferences{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // using TransferHelper for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _callers;


    struct UserInfo {
        mapping(address=>uint256) rewardDebt;
        mapping(address=>uint256) rewardAmount;
        address upper;
        uint256 joinTimeStamp;
    }

    mapping(address=>uint256) public totalRewardAmount;
    mapping(address=>uint256) public totalRewardDebt;

    // Info of each user that tokens.
    mapping(address => UserInfo) public userInfo;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public currentPeroid = 0;

    event Withdraw(address indexed user, uint256 amount);
    event RequestWithdraw(address indexed user, uint256 amount);

    event EmergencyWithdraw(address indexed user, uint256 amount);

    address  public  usdt;

    address  public  sweeper;


    constructor(
        address _usdt,
        address _sweeper
    ) public {
        usdt = _usdt;

        sweeper = _sweeper;
    }
    function setSweeper(address _sweeper) public onlyOwner{
        sweeper = _sweeper;
    }

    function addCaller(address _addCaller) public onlyOwner returns (bool) {
        require(_addCaller != address(0), "References: _addCaller is the zero address");
        return EnumerableSet.add(_callers, _addCaller);
    }

    function delCaller(address _delCaller) public onlyOwner returns (bool) {
        require(_delCaller != address(0), "References: _delCaller is the zero address");
        return EnumerableSet.remove(_callers, _delCaller);
    }

    function getCallerLength() public view returns (uint256) {
        return EnumerableSet.length(_callers);
    }

    function isCaller(address account) public view returns (bool) {
        return EnumerableSet.contains(_callers, account);
    }

    function getCaller(uint256 _index) public view onlyOwner returns (address){
        require(_index <= getCallerLength() - 1, "References: index out of bounds");
        return EnumerableSet.at(_callers, _index);
    }

    // modifier for mint function
    modifier onlyCaller() {
        require(isCaller(msg.sender), "caller is not the Caller");
        _;
    }

    function setReferee(address upper) public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.upper==address(0x0),'referee already set');

        if(upper!=address(0x0)){
            checkLoop(upper,msg.sender);
            UserInfo storage upperUser = userInfo[upper];
            if(upperUser.joinTimeStamp==0){
                upperUser.joinTimeStamp = block.timestamp;
            }
        }
        user.upper = upper;
        user.joinTimeStamp = block.timestamp;
        
    }
    function checkLoop(address ref,address check) public view {
        UserInfo storage user = userInfo[ref];
        require(user.upper!=check,'referee loop');
        if(user.upper!=address(0x0))
        {
            checkLoop(user.upper,check);
        }
    }
    uint256 public MaxRewardLayer = 2;

    function initTable (uint256 []memory rewards) public onlyOwner{
        uint length = rewards.length;
        require(length>0 && length<3,"length limit exceeded");
        for(uint i=0;i<length;i++){
            rewardFeeRatio[i] = rewards[i];
        }
        MaxRewardLayer = length;
    }
    
    function changeReferee(address ref,address upper) public onlyOwner {
        UserInfo storage user = userInfo[ref];
        if(upper!=address(0x0)){
            checkLoop(upper,ref);
            UserInfo storage upperUser = userInfo[upper];
            if(upperUser.joinTimeStamp==0){
                upperUser.joinTimeStamp = block.timestamp;
            }
        }
        user.upper = upper;
        user.joinTimeStamp = block.timestamp;
    }

    
    mapping(uint256=>uint256) public rewardFeeRatio;

    function rewardUpper(address ref,address token,uint256 amount,address _sweeper) public override onlyCaller nonReentrant returns (uint256) {
        UserInfo storage user = userInfo[ref];
        uint256 layer = 0;
        uint256 rewardAmount = 0;
        uint256 rewardDept = 0;
        if(user.upper!=address(0x0)){
            (rewardAmount,rewardDept) = rewardLayers(user.upper,token,amount,layer);
        }
        uint256 leftAmount = amount.sub(rewardAmount);
        if(leftAmount>0){
            userInfo[_sweeper].rewardAmount[token] = userInfo[_sweeper].rewardAmount[token].add(leftAmount);
            TransferHelper.safeTransfer(token,_sweeper,leftAmount);
        }
        totalRewardAmount[token] = totalRewardAmount[token].add(amount);
    }

    function rewardLayers(address ref,address token,uint256 amount,uint256 layer) internal returns (uint256 rewardAmount,uint256 rewardDept) {
        rewardAmount = amount.mul(rewardFeeRatio[layer]).div(100);
        if(rewardAmount>0){
            UserInfo storage user = userInfo[ref];
            user.rewardAmount[token] = user.rewardAmount[token].add(rewardAmount);
            if(IERC20(token).balanceOf(address(this))>=rewardAmount){
                user.rewardDebt[token] = user.rewardDebt[token].add(rewardAmount);
                rewardDept = rewardAmount;
                TransferHelper.safeTransfer(token,ref,rewardAmount);

            }
            if(layer < MaxRewardLayer && user.upper!=address(0x0)){
                (uint nextRewardAmount,uint nextRewardDept) = rewardLayers(user.upper,token,amount,layer.add(1));
                rewardAmount = rewardAmount.add(nextRewardAmount);
                rewardDept = rewardDept.add(rewardDept);
            }
        }

    }

    function pendingWithdraw(address user,address token) public view returns(uint256){
        UserInfo storage user = userInfo[msg.sender];
        return user.rewardAmount[token].sub(user.rewardDebt[token]);        

    }
    function withdraw(address token) public nonReentrant override {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amount = user.rewardAmount[token].sub(user.rewardDebt[token]);
        require(amount>0,"No more bonus");
        
        require(IERC20(token).balanceOf(address(this))>=amount,'token not enough now');
        require(totalRewardAmount[token].sub(totalRewardDebt[token])>=amount,'token reward ?');
        totalRewardDebt[token] = totalRewardDebt[token].add(amount);
        user.rewardDebt[token] = user.rewardDebt[token].add(amount);
        IERC20(token).safeTransfer(msg.sender,amount);
        emit Withdraw(msg.sender, amount);
    }



}
