// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../interfaces/IAdmin.sol";
import "../interfaces/IExecutor.sol";

/// @notice Custom access control manager for FrankenDAO
/// @dev This functionality is inherited by Governance.sol and Staking.sol
abstract contract Admin is IAdmin {
    /// @notice Founder multisig
    address public founders;

    /// @notice Council multisig
    address public council;

    /// @notice Executor contract address for passed governance proposals
    IExecutor public executor;

    /// @notice Admin that only has the power to pause and unpause staking
    /// @dev This will be a EOA used by the team for easy pausing and unpausing
    /// @dev This address is changeable by governance if the community thinks the team is misusing this power
    address public pauser;

    /// @notice Pending founder addresses for this contract
    /// @dev Only founders is two-step, because errors in transferring other admin addresses can be corrected by founders
    address public pendingFounders;

    /// @notice Error thrown for an unauthorized transaction
    error NotAuthorized();

    /////////////////////////////
    ///////// MODIFIERS /////////
    /////////////////////////////

    /// @notice Modifier for functions that can only be called by the Executor contract
    /// @dev This is for functions that only Governance is able to call
    modifier onlyExecutor() {
        if(msg.sender != address(executor)) revert Unauthorized();
        _;
    }

    /// @notice Modifier for functions that can only be called by the Council or Founder multisigs
    modifier onlyAdmins() {
        if(msg.sender != founders && msg.sender != council) revert Unauthorized();
        _;
    }

    /// @notice Modifier for functions that can only be called by the Pauser
    modifier onlyPauser() {
        if(msg.sender != pauser) revert Unauthorized();
        _;
    }

    /// @notice Modifier for functions that can only be called by either multisig or the Executor contract
    modifier onlyExecutorOrAdmins() {
        if (
            msg.sender != address(executor) && 
            msg.sender != council && 
            msg.sender != founders
        ) revert Unauthorized();
        _;
    }

    /////////////////////////////
    ////// ADMIN TRANSFERS //////
    /////////////////////////////

    /// @notice Begins transfer of founder rights. The newPendingFounders must call `_acceptFounders` to finalize the transfer.
    /// @param _newPendingFounders New pending founder.
    /// @dev This doesn't use onlyAdmins because only Founders have the right to set new Founders.
    function setPendingFounders(address _newPendingFounders) external {
        if (msg.sender != founders) revert NotAuthorized();
        emit NewPendingFounders(pendingFounders, _newPendingFounders);
        pendingFounders = _newPendingFounders;
    }

    /// @notice Accepts transfer of founder rights. msg.sender must be pendingFounders
    function acceptFounders() external {
        if (msg.sender != pendingFounders) revert NotAuthorized();
        emit NewFounders(founders, pendingFounders);
        founders = pendingFounders;
        pendingFounders = address(0);
    }

    /// @notice Transfers council address to a new multisig
    /// @param _newCouncil New address for council
    /// @dev This uses onlyAdmin because either the Council or the Founders can set a new Council.
    function setCouncil(address _newCouncil) external onlyAdmins {
        emit NewCouncil(council, _newCouncil);
        council = _newCouncil;
    }

    /// @notice Accepts transfer of council rights. msg.sender must be pendingCouncil
    function setPauser(address _newPauser) external onlyExecutorOrAdmins {
        emit NewPauser(pauser, _newPauser);
        pauser = _newPauser;
    }
}

