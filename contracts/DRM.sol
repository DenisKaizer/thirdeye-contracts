pragma solidity ^0.4.0;


contract DRMFactory {

  address public DRMs;

  function createDRM() {
    DRMs.push(0x0);
  }

  function getDRMs() returns(address[]) {
    return DRMs;
  }
}

contract DRM {

  uint256 public rewardForArbitrators;
  uint8 arbitratorsCount;
  uint16 public votesForReviewer;
  uint16 public votesForCustomer;
  uint16 votesCount;

  uint8 public drmDecission; // 1 - customer win, 2 - reviwer win, 3 - needRevote

  mapping (address => bool) arbitrators;

  modifier onlyArbitrator() {
    require(arbitrators[msg.sender]);
    _;
  }

  function DRM() {

  }

  event ReviewerWin();
  event CustomerWin();
  event NeedRevote();

  function voteForReviewer() onlyArbitrator {
    arbitrators[msg.sender] = false;
    votesForReviewer += 1;
    if (votesCount == arbitratorsCount) {

      if (votesForReviewer > votesForCustomer) {
        ReviewerWin();
        drmDecission = 2;
      }
      else {
        if (votesForCustomer > votesForReviewer) {
          CustomerWin();
          drmDecission = 1;
        }
        else {
          NeedRevote();
          drmDecission = 3;
        }
      }
    }
  }

  function voteForCustomer() onlyArbitrator {
    arbitrators[msg.sender] = false;
    votesForCustomer += 1;
    if (votesCount == arbitratorsCount) {

      if (votesForReviewer > votesForCustomer) {
        ReviewerWin();
        drmDecission = 2;
      }
      else {
        if (votesForCustomer > votesForReviewer) {
          CustomerWin();
          drmDecission = 1;
        }
        else {
          NeedRevote();
          drmDecission = 3;
        }
      }
    }
  }
  //function changeArbitrator

  //function restartVote
}

