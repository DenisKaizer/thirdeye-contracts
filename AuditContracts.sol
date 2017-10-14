import "./Permissions.sol";

contract PermissionExtension {

  address public permissionsContractAddress = 0xc3c72da7753cd1cf119a67ff84c11abb21f9b587;

  function setPerm(address allowedAddress, bytes32 levelName) internal {
    Permissions(permissionsContractAddress).setPermission(allowedAddress, levelName);
  }

  function setAdmin(address allowedAddress) internal {
    Permissions(permissionsContractAddress).setAdminPerms(allowedAddress);
  }

  function checkPerm(address checkingAddress, bytes32 levelName) internal returns(bool) {
    bool check = Permissions(permissionsContractAddress).checkPermission(checkingAddress, levelName);
    return check;
  }
  /*
    function setPermissionsContractAddress(address _permissionsContractAddress)  {
      permissionsContractAddress = _permissionsContractAddress;
    }
  */
}

contract CompanyFactory is PermissionExtension {

  address owner = msg.sender;

  mapping (address => address ) public companies;
  // msg.sender => CompanyAddress

  function createCompany(bytes32 name) {
    companies[msg.sender] = new Company(name, msg.sender);
    setAdmin(companies[msg.sender]);
  }
}

contract Company is PermissionExtension {

  bytes32 public name;
  address public owner;
  address[] public codes; // [codeAddress]
  uint256 public codeCount;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function Company(bytes32 _name, address _owner) {
    name = _name;
    owner = _owner;
  }

  event Log(uint);

  function addCode(string keyForCode, string behavior, string agenda, uint256 critical, uint256 major, uint256 minor, uint256 bountyAmount) onlyOwner payable {
    codeCount += 1;
    address newCodeAddress = new Code(keyForCode, behavior, agenda, critical, major, minor, owner, bountyAmount);
    codes.push(newCodeAddress);
    setAdmin(newCodeAddress);
  }
}


contract Code is PermissionExtension {

  struct Rewards {
  uint256 critical;
  uint256 major;
  uint256 minor;
  }

  string public keyForCode;
  string public behavior;
  string public agenda;

  uint256 public bountyAmount;
  uint256 public openClaimCount;
  uint256 public claimCount;

  uint256 sumOfBountyForClaims;

  bool public isStopped;
  bool public isOpen;

  address owner;
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

  function Code(string _keyForCode, string _behavior, string _agenda, uint256 _critical, uint256 _major, uint256 _minor, address _owner, uint256 _bountyAmount) {

    keyForCode = _keyForCode;
    behavior = _behavior;
    agenda = _agenda;
    bountyAmount = _bountyAmount;
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
    newClaimAddress =  new Claim(lineStart, lineEnd, comment, category, msg.sender, owner);
    openClaims.push(newClaimAddress);
    openClaimCount += 1;
    claims.push(newClaimAddress); //?
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

  // delete claim
  function closeClaim(address closingClaimAddress) internal {
    // to do check permissions
    //openClaims.delete();
    claimCount -= 1;
  }
}

contract Claim is PermissionExtension {

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
  address codeOwner;


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function Claim(uint256 _lineStart, uint256 _lineEnd, string _comment, bytes32 _category, address _owner, address _codeOwner) {
    lineRange.lineStart = _lineStart;
    lineRange.lineEnd = _lineEnd;
    comment = _comment;
    category = _category;
    owner = _owner;
    codeOwner = _codeOwner;
  }

  function accept() {
    require(msg.sender == codeOwner);
  }

  function decline(bytes32 _declinesComment) { // ?
    require(msg.sender == codeOwner);
    declinesComment = _declinesComment;
    declined = true;
  }

  function cancelClaim() onlyOwner {
    isOpen = false;
    // delete claim at Code address
  }

  function acceptAnswer() onlyOwner {
    require(declined);
    // return money to customer
  }

  function startDRM() {
    require(declined);
  address DRMaddress = new DRM()
  }

  function close() internal {
    isOpen = false;
  }
}


contract Stats {

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
  }
}






