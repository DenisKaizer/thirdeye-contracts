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
}

contract Screening is Ownable {

  struct Rewards {
  uint256 minorReward;
  uint256 majorReward;
  uint256 criticalReward;
  }
  uint256 public totalAmount;

  string public title;

  bytes32 fileHash;
  bytes32 agendaHash;
  bytes32 descriptionHash;

  address[] public openClaims;
  address public factory;

  Rewards rewards;

  bool public screeningActive;

  modifier notOpenClaims() {
    _;
  }

  modifier onlyClaim() {
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
    ScreeningFactory(factory).deleteScreening();
    // event
    // and delete in factory
  }

  function depositExtraMoney() onlyOwner payable {
    totalAmount += msg.value;
  }

  event reportCreating();

  function  createReport() public {
    reportCreating;
  }
}

