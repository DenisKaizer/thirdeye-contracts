pragma solidity ^0.4.15;

contract Ownable {

  address public owner;

  function Ownable() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}

contract ERC20Screening {

  address dataStoreAddress = 0x0;

  function ERC20Screening(
    address tokenAddress,
    bytes32 _fileHash,
    bytes32 _descriptionHash,
    uint256 _totalReward,
    uint256 _minorReward,
    uint256 _majorReward,
    uint256 _criticalReward
    )
  {

  }
}
