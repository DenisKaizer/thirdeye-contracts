pragma solidity ^0.4.0;


contract DataStore {

  event createScreening(address, uint);

  event deployScreeningFactory(address, uint);


  function callEvent(uint version) {
    createScreening(msg.sender, version);
  }

  function deployScreeningFactory(uint version) {
    deployScreeningFactory(msg.sender, version);
  }
}