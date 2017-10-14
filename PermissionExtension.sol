pragma solidity ^0.4.15;

import "./Permissions.sol";


contract PermissionExtension {

  address public permissionsContractAddress = 0x85cf839b9c37b3a477c0e1df70ad36b5d016107e;

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