import "./PermissionExtension.sol";

contract Stats is PermissionExtension {
  struct ReviewerStats {
  uint256 sumOfBounties;
  uint256 countOfClaims;
  uint256 countOfCriticalBugs;
  uint256 countOfMinorBugs;
  uint256 countOfMajorBugs;
  uint256 countOfDeclinedBugs;
  }

  struct ContractorStats {
  uint256 sumOfPaid;
  uint256 countOfCodes;
  uint256 countOfDeclined;
  }

  mapping (address => ReviewerStats) public reviewerStatistics;
  mapping (address => ContractorStats) public contactorStatistics;

  function changeReviewerStatistics(address reviewerAddress, uint bounty, bytes32 category) {
    require(checkPerm(msg.sender, "Claim"));
    reviewerStatistics[reviewerAddress].sumOfBounties += bounty;
    reviewerStatistics[reviewerAddress].countOfClaims += 1;
    if (category == "critical") {
      reviewerStatistics[reviewerAddress].countOfCriticalBugs += 1;
    }
    else {
      if (category == "major") {
        reviewerStatistics[reviewerAddress].countOfMajorBugs += 1;
      }
      else {
        reviewerStatistics[reviewerAddress].countOfMinorBugs += 1;
      }
    }
  }
  function changeReviewerStatistics(address reviewerAddress) {
    require(checkPerm(msg.sender, "Claim"));
    reviewerStatistics[reviewerAddress].countOfClaims += 1;
    reviewerStatistics[reviewerAddress].countOfDeclinedBugs += 1;
  }
  function changeContractorStatistics(address contractorAddress, bytes32 answer, uint256 sum) {
    require(checkPerm(msg.sender, "Claim"));
    if (answer == "decline") {
      contactorStatistics[contractorAddress].countOfDeclined += 1;
    }
    else {
      contactorStatistics[contractorAddress].sumOfPaid += sum;
    }
  }

  function changeContractorStatistics(address contractorAddress) {
    require(checkPerm(msg.sender, "Code"));
    contactorStatistics[contractorAddress].countOfCodes += 1;
  }

}
