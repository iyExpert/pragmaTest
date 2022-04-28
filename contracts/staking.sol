// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract staking is Ownable {
  // Library usage
  using SafeMath for uint;

  struct stakingInfo {
      uint amount;
      uint alreadyWithdrawn;
      uint releaseDate; //update release date after each stake
  }
  
  mapping (address => bool) public validTokens; //valid Token addresses
  mapping (address => mapping(address => stakingInfo)) public StakeMap; //tokenAddr to user to stake amount
  mapping (address => uint) public tokenTotalStaked; //tokenAddr to total token staked
    
  // Events
  event tokensStaked(address _from, uint _amount);
  event TokensUnstaked(address _to, uint _amount);

  modifier isValidToken(address _tokenAddr){
    require(validTokens[_tokenAddr]);
    _;
  }

  /**
  * add token address 
  */
  function addToken( address _tokenAddr) onlyOwner external {
    validTokens[_tokenAddr] = true;
  }
    
  /**
  * remove token address
  */
  function removeToken( address _tokenAddr) onlyOwner external {
    validTokens[_tokenAddr] = false;
  }

  /**
  * Stake tokens
  */
  function stake(uint _amount, address _tokenAddr, uint _daysCount) isValidToken(_tokenAddr) external payable returns (bool){
    require(_amount <= IERC20(_tokenAddr).balanceOf(msg.sender), "Not enough STATE tokens in your wallet, please try lesser amount");
    require(IERC20(_tokenAddr).transferFrom(msg.sender, address(this), _amount));

    if (StakeMap[_tokenAddr][msg.sender].amount == 0){
      StakeMap[_tokenAddr][msg.sender].amount = _amount;
      StakeMap[_tokenAddr][msg.sender].releaseDate = block.timestamp + _daysCount * 1 days;
    }else{
      StakeMap[_tokenAddr][msg.sender].amount = StakeMap[_tokenAddr][msg.sender].amount.add(_amount);
      StakeMap[_tokenAddr][msg.sender].releaseDate = block.timestamp + _daysCount * 1 days;
    }
    tokenTotalStaked[_tokenAddr] = tokenTotalStaked[_tokenAddr].add(_amount);

    emit tokensStaked(msg.sender, _amount);
    return true;
  }

  /**
  * Unstake tokens
  */
  function unstake(uint _amount, address _tokenAddr) isValidToken(_tokenAddr) external payable returns (bool){
    require(StakeMap[_tokenAddr][msg.sender].amount > 0);
    require(block.timestamp > StakeMap[_tokenAddr][msg.sender].releaseDate, "Tokens are only available after correct time period has elapsed");
    require(IERC20(_tokenAddr).transfer(msg.sender, _amount));

    tokenTotalStaked[_tokenAddr] = tokenTotalStaked[_tokenAddr].sub(_amount);
    StakeMap[_tokenAddr][msg.sender].alreadyWithdrawn = StakeMap[_tokenAddr][msg.sender].alreadyWithdrawn.add(_amount);

    emit TokensUnstaked(msg.sender, _amount);
    return true;
  }

  /**
  * get User Staking Info 
  */
  function getUserInfo(address _tokenAddr) isValidToken(_tokenAddr) external view returns(stakingInfo memory){
    return StakeMap[_tokenAddr][msg.sender];
  }

  
  /**
  * get tokenTotalStaked
  */
  function getTokenTotalStaked(address _tokenAddr) isValidToken(_tokenAddr) external view returns(uint){
    return tokenTotalStaked[_tokenAddr];
  }
}