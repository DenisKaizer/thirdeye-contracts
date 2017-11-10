pragma solidity ^0.4.0;

import "./Ownable.sol";

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