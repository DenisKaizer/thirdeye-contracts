pragma solidity ^0.4.0;

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

contract DataStore is Ownable {

  mapping (address => bool) screeningFactorys;

  event CreateScreening(address);
  event DeployScreeningFactory(address);

  function addNewScreeningFactory(address newScreeningFactory) onlyOwner {
    screeningFactory[newScreeningFactory] = true;
  }

  function deleteScreeningFactory(address newScreeningFactory) onlyOwner {
    screeningFactory[newScreeningFactory] = true;
  }

  function createScreening(address screeningAddress) {
    CreateScreening(screeningAddress);
  }

  function deployScreeningFactory() {
    DeployScreeningFactory(msg.sender);
  }
}