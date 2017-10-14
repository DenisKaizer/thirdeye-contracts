pragma solidity ^0.4.15;

import "./Permissions.sol";


contract PermissionExtension {

  address public permissionsContractAddress = 0x5e72914535f202659083db3a02c984188fa26e9f;

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