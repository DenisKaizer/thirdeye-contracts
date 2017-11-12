pragma solidity ^0.4.17;

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

  mapping (address => bool) public screeningFactorys ;
  address[] screenings;

  event DeployScreeningFactory(address);

  function createScreening(address screeningAddress) {
    require(screeningFactorys[msg.sender]);
    screenings.push(screeningAddress);
  }

  function deployScreeningFactory(address screeningFactoryAddress) onlyOwner {
    screeningFactorys[screeningFactoryAddress] = true;
    DeployScreeningFactory(screeningFactoryAddress);
  }

  function getScreenings() returns(address[]) {
    return screenings;
  }
}