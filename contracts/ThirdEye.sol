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

  address[] public screenings;

  mapping (address => uint) public screeningsIndex;
  // screening = > index for delete
  mapping (address => uint[]) public ownerScreenings; // ?
  // owner => index's

  event ScreeningCreate(address);

  function ScreeningFactory() {
    screenings.push(0x0);
  }

  function createScreening (
  string title,
  bytes32 fileHash,
  bytes32 agendaHash,
  bytes32 descriptionHash,
  uint256 minorReward,
  uint256 majorReward,
  uint256 criticalReward
  ) payable returns (address)
  {
    require(msg.value >= criticalReward);
    address screening = new Screening(
    msg.sender,
    title,
    fileHash,
    agendaHash,
    descriptionHash,
    minorReward,
    majorReward,
    criticalReward
    );

    screenings.push(screening);
    ownerScreenings[msg.sender].push(screenings.length - 1);
    screeningsIndex[screening] = screenings.length - 1;
    bool isSent = screening.call.gas(3000000).value(msg.value)();
    require(isSent);
    ScreeningCreate(screening);
    return screening;
  }

  function deleteScreening() {
    uint index = screeningsIndex[msg.sender];
    delete screenings[index];
  }

  function getScreeningLength() view returns(uint) {
    return screenings.length;
  }

  function getScreenings() view returns(address[]) {
    return screenings;
  }
}

contract Screening is Ownable {

  struct Rewards {
  uint256 minorReward;
  uint256 majorReward;
  uint256 criticalReward;
  }
  uint256 public totalAmount;

  string public title;

  bytes32 public fileHash;
  bytes32 public agendaHash;
  bytes32 public descriptionHash;

  address[] public openClaims;
  mapping (address => uint) public claimsIndex;
  mapping (address => uint[]) public ownerClaims;

  address public factory;

  Rewards public rewards;

  bool public screeningActive;

  modifier notOpenClaims() {
    require(openClaims.length <= 1);
    _;
  }

  modifier onlyClaim() {
    require(claimsIndex[msg.sender] >= 0);
    _;
  }

  function Screening(
  address _owner,
  string _title,
  bytes32 _fileHash,
  bytes32 _agendaHash,
  bytes32 _descriptionHash,
  uint256 _minorReward,
  uint256 _majorReward,
  uint256 _criticalReward)
  {
    factory = msg.sender;
    owner = _owner;
    title = _title;
    fileHash = _fileHash;
    agendaHash = _agendaHash;
    descriptionHash =_descriptionHash;
    rewards.minorReward = _minorReward;
    rewards.majorReward = _majorReward;
    rewards.criticalReward = _criticalReward;
    screeningActive = true;
    openClaims.push(0x0);
  }

  function () payable{
    totalAmount = msg.value;
  }

  function getClaims() view returns(address[]) {
    return openClaims;
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
    ScreeningFactory(factory).deleteScreening();
    // event
    // and delete in factory
  }

  function depositExtraMoney() onlyOwner payable {
    totalAmount += msg.value;
  }

  function payReward(address reviwer, uint valueToPay) onlyClaim {
    bool isSent = reviwer.call.gas(3000000).value(valueToPay)();
    require(isSent);
    uint index = claimsIndex[msg.sender];
    delete openClaims[index];
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

    openClaims.push(claim);
    claimsIndex[claim] = openClaims.length - 1;
    ownerClaims[msg.sender].push(openClaims.length - 1);
    claimCreating(claim);
  }
}

contract Claim is Ownable {

  uint lineNumber;
  bytes32 comment;
  uint8 category;
  address screeningOwner;
  address screening;
  uint potentialReward;

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
  }

  modifier onlyScreeningOwner() {
    require(msg.sender == screeningOwner);
    _;
  }

  function accept() onlyScreeningOwner {
    Screening(screening).payReward(owner, potentialReward);
  }

  function reject() onlyScreeningOwner {

  }

  function cancel() onlyOwner {

  }
}

