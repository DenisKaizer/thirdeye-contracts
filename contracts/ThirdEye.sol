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
}

contract ScreeningFactory {

  event ScreeningCreate(address);

  function createScreening (
  bytes32 fileHash,
  bytes32 descriptionHash,
  uint256 minorReward,
  uint256 majorReward,
  uint256 criticalReward
  ) payable returns (address)
  {
    require(msg.value >= criticalReward);
    address screening = new Screening(
    msg.sender,
    fileHash,
    descriptionHash,
    minorReward,
    majorReward,
    criticalReward
    );

    bool isSent = screening.call.gas(3000000).value(msg.value)();
    require(isSent);
    ScreeningCreate(screening);
    return screening;
  }

}

contract Screening is Ownable {

  struct Rewards {
  uint256 minorReward;
  uint256 majorReward;
  uint256 criticalReward;
  }
  uint256 public totalAmount;

  bytes32 public fileHash;
  bytes32 public descriptionHash;

  mapping (address => bool) public claims;
  uint openClaims;

  address public factory;

  Rewards public rewards;

  bool public screeningActive;

  modifier notOpenClaims() {
    require(openClaims == 0);
    _;
  }

  modifier onlyClaim() {
    require(claims[msg.sender]);
    _;
  }

  function Screening(
  address _owner,
  bytes32 _fileHash,
  bytes32 _descriptionHash,
  uint256 _minorReward,
  uint256 _majorReward,
  uint256 _criticalReward)
  {
    factory = msg.sender;
    owner = _owner;
    fileHash = _fileHash;
    descriptionHash =_descriptionHash;
    rewards.minorReward = _minorReward;
    rewards.majorReward = _majorReward;
    rewards.criticalReward = _criticalReward;
    screeningActive = true;
  }

  function () payable{
    totalAmount = msg.value;
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

  function depositExtraMoney() onlyOwner payable {
    totalAmount += msg.value;
  }

  function payReward(address reviwer, uint valueToPay) onlyClaim {
    bool isSent = reviwer.call.gas(3000000).value(valueToPay)();
    require(isSent);
    claims[msg.sender] == false;
  }

  function closeClaim() onlyClaim {
    claims[msg.sender] == false;
  }

  event claimCreating(address);

  function  createClaim(
    uint8 category,
    bytes32 comment,
    uint lineNumber)
    public
  {
    require(this.balance >= rewards.minorReward);
    uint potentialReward = rewards.minorReward;
    if (category == 2) {
      require(this.balance >= rewards.majorReward);
      potentialReward = rewards.majorReward;
    }
    else {
      if (category == 3) {
        require(this.balance >= rewards.criticalReward);
        potentialReward = rewards.criticalReward;
      }
    }
    address claim = new Claim (
    msg.sender,
    category,
    comment,
    lineNumber,
    owner,
    potentialReward);
    claimCreating(claim);
    claims[claim] = true;
  }
}

contract Claim is Ownable {

  uint lineNumber;
  bytes32 comment;
  uint8 category;
  address screeningOwner;
  address screening;
  uint potentialReward;
  uint8 status;


  function Claim (
    address _owner,
    uint8 _category,
    bytes32 _comment,
    uint _lineNumber,
    address _screeningOwner,
    uint _potentialReward)
  {
    owner = _owner;
    lineNumber = _lineNumber;
    comment = _comment;
    category = _category;
    screeningOwner = _screeningOwner;
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

  function accept() onlyScreeningOwner {
    Screening(screening).payReward(owner, potentialReward);
    status = 3;
  }

  function reject() onlyScreeningOwner {
    status = 2;
  }

  function acceptRejection() onlyOwner onlyRejected {
    Screening(screening).closeClaim();
    status = 3;
  }

  function cancel() onlyOwner {
    Screening(screening).closeClaim();
    status = 3;
  }
}

