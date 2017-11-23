pragma solidity ^0.4.17;

import "./DataStore.sol";


contract ScreeningFactory {

  event CreateScreening(address);

  address dataStoreAddress;

  function ScreeningFactory(address _dataStoreAddress) {
    dataStoreAddress = _dataStoreAddress;
  }

  function createScreening (
    bytes32 fileHash,
    bytes32 descriptionHash,
    uint256 minorReward,
    uint256 majorReward,
    uint256 criticalReward
  )
  payable returns (address) {
    require(msg.value >= criticalReward);

    address screening = new Screening(
      msg.sender,
      fileHash,
      descriptionHash,
      minorReward,
      majorReward,
      criticalReward
    );
    // is sent
    require(screening.call.gas(3000000).value(msg.value)());
    ScreeningCreate(screening);
    DataStore(dataStoreAddress).createScreening(screening);
    return screening;
  }
}

contract Screening is Ownable {

  struct Rewards {
    uint256 minorReward;
    uint256 majorReward;
    uint256 criticalReward;
  }
  uint256 public totalReward;
  uint256 reservedBalance;

  bytes32 public fileHash;
  bytes32 public descriptionHash;

  mapping (address => bool) public claims;
  address[] screeningsClaims;
  uint openClaims;

  address public factory;

  Rewards public rewards;

  bool public screeningActive;

  function Screening(
    address _owner,
    bytes32 _fileHash,
    bytes32 _descriptionHash,
    uint256 _minorReward,
    uint256 _majorReward,
    uint256 _criticalReward
  ) {
    factory = msg.sender;
    owner = _owner;
    fileHash = _fileHash;
    descriptionHash =_descriptionHash;
    rewards.minorReward = _minorReward;
    rewards.majorReward = _majorReward;
    rewards.criticalReward = _criticalReward;
    screeningActive = true;
  }

  modifier notOpenClaims() {
    require(openClaims == 0);
    _;
  }

  modifier onlyClaim() {
    require(claims[msg.sender]);
    _;
  }

  function pauseScreening() onlyOwner {
    screeningActive = false;
    // event
  }

  function startScreening() onlyOwner {
    screeningActive = true;
    // event
  }

  function closeScreening() onlyOwner notOpenClaims {
    screeningActive = false;
    owner.transfer(this.balance);
  }


  //function depositExtraMoney() onlyOwner payable {
    //totalReward += msg.value;
  //}

  function payReward(address reviwer, uint valueToPay) onlyClaim {
    // is sent
    require(reviwer.call.gas(3000000).value(valueToPay)());
    claims[msg.sender] == false;
    reservedBalance -= valueToPay;
    openClaims -= 1;
  }

  function closeClaim(uint256 potentialReward) onlyClaim {
    claims[msg.sender] == false;
    reservedBalance -= potentialReward;
    openClaims -= 1;
  }

  event CreateClaim(address);

  function  createClaim(
    uint8 category,
    bytes32 comment,
    uint lineNumber
  )
  public {
    require((this.balance - reservedBalance) >= rewards.minorReward);

    uint potentialReward = rewards.minorReward;  // reward to pay if claim accepted

    if (category == 2) {
      require((this.balance - reservedBalance) >= rewards.majorReward);
      potentialReward = rewards.majorReward;
    }
    else {
      if (category == 3) {
        require((this.balance - reservedBalance) >= rewards.criticalReward);
        potentialReward = rewards.criticalReward;
      }
    }

    address claim = new Claim (
      owner,
      msg.sender,
      lineNumber,
      category,
      comment,
      potentialReward
    );

    reservedBalance += potentialReward;
    claimCreating(claim);
    claims[claim] = true;
    screeningsClaims.push(claim);
    openClaims += 1;
  }

  function getClaims() returns(address[]) {
    return screeningsClaims;
  }

  function () payable {
    totalReward += msg.value;
  }
}

contract Claim is Ownable {

  address screeningOwner;
  address screening;

  uint lineNumber;
  uint8 category;
  bytes32 comment;
  uint potentialReward;
  uint8 status; // 1 - pending, 2 - accepted by customer, 3 - rejected by customer, 4 - rejection accepted

  function Claim (
    address _screeningOwner,
    address _owner,
    uint _lineNumber,
    uint8 _category,
    bytes32 _comment,
    uint _potentialReward
  ) {
    screeningOwner = _screeningOwner;
    owner = _owner;
    lineNumber = _lineNumber;
    category = _category;
    comment = _comment;
    potentialReward = _potentialReward;
    screening = msg.sender;
    status = 1;
  }

  modifier onlyScreeningOwner() {
    require(msg.sender == screeningOwner);
    _;
  }

  modifier onlyRejected() {
    require(status == 2);
    _;
  }

  event Accepted();

  function accept() onlyScreeningOwner {
    Screening(screening).payReward(owner, potentialReward);
    status = 3;
    Accepted();
  }

  event Rejected();

  function reject() onlyScreeningOwner {
    status = 2;
    Rejected();
  }

  function acceptRejection() onlyOwner onlyRejected {
    Screening(screening).closeClaim(potentialReward);
    status = 3;
  }

  function cancel() onlyOwner {
    Screening(screening).closeClaim(potentialReward);
    status = 3;
  }
}
