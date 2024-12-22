// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";

contract DeployMyGovernor is Script {
    uint256 public constant MIN_DELAY = 3600; // 1 hour
    uint256 public constant QUORUM_PERCENTAGE = 4;
    uint256 public constant VOTING_PERIOD = 50400; // About a week
    uint256 public constant VOTING_DELAY = 7200; // 1 day

    function run() external returns (MyGovernor, TimeLock, Box, GovToken) {
        vm.startBroadcast();

        GovToken token = new GovToken(msg.sender);
        token.delegate(msg.sender);

        TimeLock timelock = new TimeLock(MIN_DELAY, new address[](0), new address[](0));

        MyGovernor governor = new MyGovernor(token, timelock);

        Box box = new Box(msg.sender);

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, msg.sender);

        box.transferOwnership(address(timelock));

        vm.stopBroadcast();
        return (governor, timelock, box, token);
    }
}
