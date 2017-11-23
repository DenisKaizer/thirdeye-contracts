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

  mapping (address => bool) public screeningFactories;
  address[] public screenings;

  event DeployScreeningFactory(address);
  event CreateScreening(address);
  event CreateClaim(address);

  function createScreening(address screeningAddress) {
    require(screeningFactories[msg.sender]);
    screenings.push(screeningAddress);
  }

  function createClaim(claimAddress) {
    CreateClaim(claimAddress);
  }

  function deployScreeningFactory(address screeningFactoryAddress) onlyOwner {
    screeningFactories[screeningFactoryAddress] = true;
    DeployScreeningFactory(screeningFactoryAddress);
  }

  function getScreenings() view returns (address[]) {
    return screenings;
  }

  function clearScreenings() {
    delete screenings;
  }
}