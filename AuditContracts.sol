pragma solidity ^0.4.15;


import "./PermissionExtension.sol";
import "./Stats.sol";


contract StatsExtension {

  address public statsContractAddress = 0x0bbe375ea9facfba96bd727128514a4a3e5192d8;

  function changeReviewer(address reviewerAddress, uint bounty, bytes32 category) {
    Stats(statsContractAddress).changeReviewerStatistics(reviewerAddress, bounty, category);
  }
  function changeReviewer(address reviewerAddress) {
    Stats(statsContractAddress).changeReviewerStatistics(reviewerAddress);
  }

  function changeContractor(address contractorAddress, bytes32 answer, uint256 sum) {
    Stats(statsContractAddress).changeContractorStatistics(contractorAddress, answer, sum);
  }

  function changeContractor(address contractorAddress) {
    Stats(statsContractAddress).changeContractorStatistics(contractorAddress);
  }
}


contract CompanyFactory is PermissionExtension {

  address owner = msg.sender;

  // msg.sender => CompanyAddress
  mapping (address => address) public companies;

  function createCompany(bytes32 name, string fileHash) {
    companies[msg.sender] = new Company(name, msg.sender, fileHash);
    setAdmin(companies[msg.sender]);
  }
}


contract Company is PermissionExtension {

  bytes32 public name;
  address public owner;
  address[] public screenings; // [codeAddress]
  uint256 public screeningCount;
  string public fileHash;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function Company(bytes32 _name, address _owner, string _fileHash) {
    name = _name;
    owner = _owner;
    fileHash = _fileHash;
  }

  function addScreening(string keyForScreening, string behavior, string agenda, uint256 critical, uint256 major, uint256 minor, uint256 bountyAmount) onlyOwner payable {
    screeningCount += 1;
    address newScreeningAddress = new Screening(keyForScreening, behavior, agenda, critical, major, minor, owner);
    screenings.push(newScreeningAddress);
    setAdmin(newScreeningAddress);
    setPerm(newScreeningAddress, "Screening");
  }
}


contract Screening is PermissionExtension {

  struct Rewards {
  uint256 critical;
  uint256 major;
  uint256 minor;
  }

  string public keyForScreening;
  string public behavior;
  string public agenda;

  uint256 public bountyAmount;
  uint256 public openClaimCount;
  uint256 public claimCount;

  uint256 sumOfBountyForClaims;

  bool public isStopped;
  bool public isOpen;

  address owner;

  mapping (address => uint256) openClaimsIndexes;
  mapping (address => uint256) claimsIndexes;
  address[] public openClaims; // ?
  address[] public claims; // ?

  Rewards public rewards;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  //function setBountyAmount() payable onlyOwner {
  //    bountyAmount = msg.value;
  //}

  function Screening(string _keyForScreening, string _behavior, string _agenda, uint256 _critical, uint256 _major, uint256 _minor, address _owner) {

    keyForScreening = _keyForScreening;
    behavior = _behavior;
    agenda = _agenda;
    //bountyAmount = _bountyAmount;
    rewards.critical = _critical;
    rewards.major = _major;
    rewards.minor = _minor;
    owner = _owner;
    isOpen = true;
  }

  function addClaim(uint256 lineStart, uint256 lineEnd, string comment, bytes32 category) {
    //to do add to claims'list
    uint potentialReward;

    if (category == "critical") {
      potentialReward = rewards.critical;
    }
    else{
      if (category == "major") {
        potentialReward = rewards.major;
      }
      else{
        potentialReward = rewards.minor;
      }
    }

    require ((sumOfBountyForClaims + potentialReward) < bountyAmount);
    address newClaimAddress;
    newClaimAddress =  new Claim(lineStart, lineEnd, comment, category, msg.sender, owner, potentialReward);
    openClaims.push(newClaimAddress);
    openClaimsIndexes[newClaimAddress] = openClaimCount;
    openClaimCount += 1;
    claims.push(newClaimAddress); //?
    claimsIndexes[newClaimAddress] = openClaimCount;
    claimCount += 1;
    setPerm(newClaimAddress, "Claim");
  }

  function stop() onlyOwner {
    isStopped = true;
  }

  function close() onlyOwner {
    require(openClaimCount == 0);
    isOpen = false;
  }

  function closeClaim() {
    require(checkPerm(msg.sender, "Claim"));
    delete openClaims[openClaimsIndexes[msg.sender]];
    openClaims.length--;
    openClaimCount -= 1;
  }
}


contract Claim is PermissionExtension, StatsExtension {

  struct LineRange{
  uint256 lineStart;
  uint256 lineEnd;
  }

  LineRange public lineRange;

  string public comment;
  bytes32 declinesComment;
  bytes32 public category;
  bool isOpen;
  bool public declined;
  address owner;
  address screeningOwner;
  address screeningAddress;
  uint256 potentialReward;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function Claim(uint256 _lineStart, uint256 _lineEnd, string _comment, bytes32 _category, address _owner, address _screeningOwner, uint256 _potentialReward) {
    lineRange.lineStart = _lineStart;
    lineRange.lineEnd = _lineEnd;
    comment = _comment;
    category = _category;
    owner = _owner;
    screeningOwner = _screeningOwner;
    screeningAddress = msg.sender;
    potentialReward = _potentialReward;
  }

  function acceptBug() {
    require(msg.sender == screeningOwner);

  }

  function declineBug(bytes32 _declinesComment) { // ?
    require(msg.sender == screeningOwner);
    declinesComment = _declinesComment;
    declined = true;
  }
  /*
    function cancelClaim() onlyOwner {
      isOpen = false;
      // delete claim at Screening address
    }
  */
  function acceptAnswer() onlyOwner {
    require(declined);
    Screening(screeningAddress).closeClaim();
    // to do return money to customer
  }

  /*
      function startDRM() {
          require(declined);
          address DRMaddress = new DRM()
      }
  */

  function close() internal {
    isOpen = false;
  }
}
