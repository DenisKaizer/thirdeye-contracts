contract Permissions {

  //mapping (bytes32 => uint) public permissionNames;
  mapping (address => bytes32) public permissions;
  mapping (address => bool) admins;

  address owner = msg.sender;

  function checkPermission(address checkingAddress, bytes32 levelName) returns (bool) {
    if (permissions[checkingAddress] == levelName) {
      return true;
    }
    return false;
  }

  function setPermission(address allowedAddress, bytes32 levelName) {
    require(admins[msg.sender] || msg.sender == owner);
    permissions[allowedAddress] = levelName;
  }

  function setAdminPerms(address allowedAddress)  {
    require(admins[msg.sender] || msg.sender == owner);
    admins[allowedAddress] = true;
  }
}
